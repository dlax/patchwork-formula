{% from "patchwork/map.jinja" import patchwork with context %}

include:
  - patchwork.user

install patchwork from targz:
  archive.extracted:
    - name: {{ patchwork.home }}
    - source: https://github.com/getpatchwork/patchwork/archive/{{ patchwork.version }}.tar.gz
    - skip_verify: true  # XXX

patchwork dependencies:
  pkg.installed:
    - pkgs:
      - python3
      - python3-pip
      - virtualenv
      - postgresql-server-dev-9.4  # Needed to build psycopg2.

patchwork virtualenv:
  virtualenv.managed:
    - name: {{ [patchwork.home, 'venv']|join('/') }}
    - requirements: {{ [patchwork.home, patchwork.distdir, 'requirements-prod.txt']|join('/') }}
    - use_wheel: true
    - python: python3
    - require:
      - pkg: patchwork dependencies
      - archive: install patchwork from targz

{{ [patchwork.home, 'static']|join('/') }}:
  file.directory:
    - user: {{ patchwork.user }}
    - group: {{ patchwork.group }}
    - require:
      - user: {{ patchwork.user }}

# vim: ft=sls
