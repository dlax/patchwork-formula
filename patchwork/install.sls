{% from "patchwork/map.jinja" import patchwork with context %}

patchwork-pkg:
  pkg.installed:
    - name: {{ patchwork.pkg }}

# vim: ft=sls
