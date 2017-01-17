{% from "patchwork/map.jinja" import patchwork with context %}

include:
  - patchwork.user
  - patchwork.install

{% set python = [patchwork.home, 'venv', 'bin', 'python']|join('/') %}
{% set basedir = [patchwork.home, patchwork.distdir]|join('/') %}
{% set manage = [basedir, 'manage.py']|join('/') %}

{% for cmd in (
    'check',
    ['loaddata', [basedir, 'fixtures', 'default_tags.xml']|join('/')]|join(' '),
    ['loaddata', [basedir, 'fixtures', 'default_states.xml']|join('/')]|join(' '),
    'collectstatic --noinput',
)%}
{{ [python, manage, cmd]|join(' ') }}:
  cmd.run:
    - runas: {{ patchwork.user }}
    - env:
      - DJANGO_SECRET_KEY: {{ patchwork.secret_key }}
    - require:
      - virtualenv: patchwork virtualenv
      - archive: install patchwork
{% endfor %}
