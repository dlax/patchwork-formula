{% from "patchwork/map.jinja" import patchwork with context %}

include:
  - patchwork.user
  - patchwork.install

{% set python = [patchwork.home, 'venv', 'bin', 'python']|join('/') %}
{% set basedir = [patchwork.home, patchwork.distdir]|join('/') %}
{% set manage = [basedir, 'manage.py']|join('/') %}

{% set check_cmd = [python, manage, 'check']|join(' ') %}

{{ check_cmd }}:
  cmd.run:
    - runas: {{ patchwork.user }}
    - require:
      - virtualenv: patchwork virtualenv
      - archive: install patchwork

{% for cmd in (
    'migrate',
    ['loaddata', [basedir, 'patchwork', 'fixtures', 'default_tags.xml']|join('/')]|join(' '),
    ['loaddata', [basedir, 'patchwork', 'fixtures', 'default_states.xml']|join('/')]|join(' '),
    'collectstatic --noinput',
)%}
{{ [python, manage, cmd]|join(' ') }}:
  cmd.run:
    - runas: {{ patchwork.user }}
    - require:
      - virtualenv: patchwork virtualenv
      - archive: install patchwork
      - cmd: {{ check_cmd }}
{% endfor %}
