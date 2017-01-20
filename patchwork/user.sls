{% from "patchwork/map.jinja" import patchwork with context %}

{{ patchwork.user }}:
  group.present:
    - name: {{ patchwork.group }}
  user.present:
    - shell: /bin/bash
    - home: {{ patchwork.home }}
    - groups:
      - {{ patchwork.group }}
  file.append:
    - name: {{ patchwork.home }}/.profile
    - text: |
        DJANGO_SECRET_KEY={{ patchwork.secret_key }}
        export DJANGO_SECRET_KEY
        PW_PYTHON={{ [patchwork.venv, 'bin', 'python']|join('/') }}
        export PW_PYTHON

# vim: ft=sls
