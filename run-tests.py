#!/usr/bin/env python

import sys
import os
import argparse
import subprocess

BASEDIR = os.path.abspath(os.path.dirname(__file__))

_formula = "patchwork"
_images = ["jessie"]


def get_tag(image, salt=False):
    tag = "{0}-formula:{1}".format(_formula, image)
    if salt:
        return tag + "_salted"
    else:
        return tag


def image_exists(image):
    # docker image accept tags only in version >= 1.8...
    # so workaround with docker history
    rc = subprocess.call("docker history -q {0} > /dev/null".format(image), shell=True)
    if rc == 0:
        return True
    elif rc == 1:
        return False
    else:
        raise RuntimeError("Cannot test if image exists")


def _build(image, salt=False, context='.'):
    dockerfile = "test/{0}.Dockerfile".format(image)
    tag = get_tag(image, salt)
    if salt:
        dockerfile_content = open(dockerfile, "rb").read()
        dockerfile_content += (
            b"\n"
            b"ADD test/minion.conf /etc/salt/minion.d/minion.conf\n"
            b"ADD test/salt /srv/salt\n"
            b"ADD test/pillar /srv/pillar\n"
            b"ADD patchwork /srv/formula/patchwork\n"
            b"RUN salt-call -l debug --hard-crash --retcode-passthrough state.highstate\n"
        )
        dockerfile = os.path.join("test", "{0}_salted.Dockerfile".format(image))
        with open(dockerfile, "wb") as fd:
            fd.write(dockerfile_content)
    subprocess.check_call([
        "docker", "build", "-t", tag, "-f", dockerfile, context,
    ])
    return tag


def build(args, remain):
    _build(args.image, args.salt)


def test(args, remain):
    """Build a salted docker image and ensure this succeeded."""
    _build(args.image, True)
    tag = get_tag(args.image, True)
    print(subprocess.check_output(["docker", "images"]))
    assert image_exists(tag)


def dev(args, remain):
    return _dev(args.image, args.salt, args.postgres, args.cmd)


def _dev(image, salt=False, postgres=False, exec_cmd=None):
    tag = get_tag(image, salt)
    if not image_exists(tag):
        _build(image, salt)
    cmd = [
        "docker", "run", "-d", "--hostname", image,
    ]
    postgres_id = None
    if postgres:
        postgres_image = _build('postgres', salt=False, context='test')

        postgres_id = subprocess.check_output([
            "docker", "run", "-d", postgres_image,
        ]).strip()
        cmd.extend(["--link", "{0}:postgres".format(postgres_id)])

    if image in ("centos7",):
        # Systemd require privileged container
        cmd.append("--privileged")

    cmd.extend([
        "-v", "{0}/test/minion.conf:/etc/salt/minion.d/minion.conf".format(BASEDIR),
        "-v", "{0}/test/salt:/srv/salt".format(BASEDIR),
        "-v", "{0}/test/pillar:/srv/pillar".format(BASEDIR),
        "-v", "{0}:/srv/formula/.".format(BASEDIR),
    ])

    cmd.append(tag)

    # Run the container default CMD as pid 1 (init system)
    docker_id = subprocess.check_output(cmd).strip()
    try:
        if exec_cmd is not None:
            proc = subprocess.Popen(
                ["docker", "exec", "-t", docker_id] + exec_cmd.split(),
                stdout=sys.stdout, stderr=sys.stderr,
            )
            return proc.wait()
        else:
            # Spawn a interactive shell in the container
            subprocess.call(["docker", "exec", "-it", docker_id, "/bin/bash"])
    finally:
        subprocess.call(["docker", "rm", "-f", docker_id])
        if postgres_id:
            subprocess.call(["docker", "rm", "-f", postgres_id])


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Test {0} formula in docker".format(_formula))
    subparsers = parser.add_subparsers(help="sub-command help")

    parser_build = subparsers.add_parser("build", help="build images")
    parser_build.add_argument("image", choices=_images)
    parser_build.add_argument("--salt", action="store_true")
    parser_build.set_defaults(func=build)

    parser_dev = subparsers.add_parser("dev", help="drop a shell in dev container")
    parser_dev.add_argument("image", choices=_images)
    parser_dev.add_argument("--salt", action="store_true")
    parser_dev.add_argument("--postgres", action="store_true",
                            help='link with a "postgres" container')
    parser_dev.add_argument("--cmd",
                            help='command to execute in the running container')
    parser_dev.set_defaults(func=dev)

    parser_test = subparsers.add_parser("test", help="provision a container and run tests on it")
    parser_test.add_argument("image", choices=_images)
    parser_test.set_defaults(func=test)

    args, remain = parser.parse_known_args()
    sys.exit(args.func(args, remain))
