{% from "patchwork/map.jinja" import patchwork with context %}

include:
  - patchwork.install

{{ [patchwork.home, patchwork.distdir, 'patchwork', 'settings', 'production.py']|join('/') }}:
  file.managed:
    - source: salt://patchwork/files/production.py.j2
    - template: jinja
    - require:
      - archive: install patchwork

{% set python = [patchwork.venv, 'bin', 'python']|join('/') %}

{{ [python, [patchwork.home, patchwork.distdir, 'manage.py']|join('/'), 'cron']|join(' ') }}:
  cron.present:
    - user: {{ patchwork.user }}
    - minute: '*/10'
    - require:
      - user: {{ patchwork.user }}
      - archive: install patchwork

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

/etc/uwsgi/sites/patchwork.ini:
  file.managed:
    - source: salt://patchwork/files/patchwork-uwsgi.ini.j2
    - makedirs: true
    - template: jinja
    - require:
      - pkg: uwsgi

/etc/systemd/system/uwsgi.service:
  file.managed:
    - source: salt://patchwork/files/uwsgi.service.j2
    - template: jinja
    - require:
      - file: /etc/uwsgi/sites/patchwork.ini
      - pkg: uwsgi
