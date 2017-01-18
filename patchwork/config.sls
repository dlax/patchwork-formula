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
