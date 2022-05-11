# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_clean = tplroot ~ '.config.clean' %}
{%- from tplroot ~ "/map.jinja" import mapdata as borgmatic with context %}

include:
  - {{ sls_config_clean }}

Borgmatic is removed:
  file.absent:
    - names:
      - {{ borgmatic.lookup.service.unit.format(name=borgmatic.lookup.service.name) }}
      - {{ borgmatic.lookup.service.timer.format(name=borgmatic.lookup.service.name) }}
  pip.removed:
    - name: {{ borgmatic.lookup.pkg.name }}
    - user: root
{%- if not borgmatic.install_global %}
    - install_options:
      - --user
{%- endif %}
