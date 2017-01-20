{% from "patchwork/map.jinja" import patchwork with context %}

include:
  - patchwork.install
  - patchwork.supervisor

python-pip:
  pkg.installed

gunicorn:
  pip.installed:
    - bin_env: {{ patchwork.venv }}
    - require:
      - virtualenv: {{ patchwork.venv }}
      - pkg: python-pip  # pip_state tries to import pip

/etc/supervisor/conf.d/patchwork.conf:
  file.managed:
    - source: salt://patchwork/files/patchwork-supervisor.conf.j2
    - template: jinja
    - require:
      - pkg: supervisor

nginx:
  pkg.installed:
    - name: nginx-full

{% set nginx_conffile = '/etc/nginx/sites-available/patchwork.conf' %}

{{ nginx_conffile }}:
  file.managed:
    - source: salt://patchwork/files/patchwork-nginx.conf.j2
    - template: jinja
    - require:
      - pkg: nginx

/etc/nginx/sites-enabled/patchwork.conf:
  file.symlink:
    - target: {{ nginx_conffile }}
    - require:
      - file: {{ nginx_conffile }}

/etc/nginx/sites-enabled/default:
  file.absent
