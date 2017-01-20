{% from "patchwork/map.jinja" import patchwork with context %}

include:
  - patchwork.install
  - patchwork.supervisor
  - patchwork.user

getmail4:
  pkg.installed

{% set getmaildir = [patchwork.home, '.getmail', 'config', patchwork.mail.address]|join('/') %}

{{ getmaildir }}:
  file.directory:
    - user: {{ patchwork.user }}
    - group: {{ patchwork.group }}
    - mode: 700
    - makedirs: true
    - require:
      - user: {{ patchwork.user }}

{{ [getmaildir, 'getmailrc']|join('/') }}:
  file.managed:
    - source: salt://patchwork/files/getmailrc.j2
    - template: jinja
    - user: {{ patchwork.user }}
    - group: {{ patchwork.group }}
    - mode: 600
    - makedirs: true
    - require:
      - file: {{ getmaildir }}

/etc/supervisor/conf.d/getmail.conf:
  file.managed:
    - source: salt://patchwork/files/getmail-supervisor.conf.j2
    - template: jinja
    - defaults:
      getmaildir: {{ getmaildir }}
    - require:
      - pkg: supervisor

# Install a modified parsemail.sh script which handles $PW_PYTHON, which is
# needed as we use a virtualenv (modifications taken from upstream).
{{ [patchwork.home, patchwork.distdir, 'patchwork/bin/parsemail.sh']|join('/') }}:
  file.managed:
    - source: salt://patchwork/files/parsemail.sh
    - replace: true
    - require:
      - archive: install patchwork
