{% from "patchwork/map.jinja" import patchwork with context %}

include:
  - patchwork.install

{{ [patchwork.home, patchwork.distdir, 'patchwork', 'settings', 'production.py']|join('/') }}:
  file.managed:
    - source: salt://patchwork/files/production.py.j2
    - template: jinja
    - require:
      - archive: install patchwork
