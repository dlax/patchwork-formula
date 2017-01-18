{% from "patchwork/map.jinja" import patchwork with context %}

include:
  - patchwork.install

python-pip:
  pkg.installed

gunicorn:
  pip.installed:
    - bin_env: {{ patchwork.venv }}
    - require:
      - virtualenv: {{ patchwork.venv }}
      - pkg: python-pip  # pip_state tries to import pip

supervisor:
  pkg.installed

/etc/supervisor/conf.d/patchwork.conf:
  file.managed:
    - source: salt://patchwork/files/patchwork-supervisor.conf.j2
    - template: jinja
    - require:
      - pkg: supervisor
