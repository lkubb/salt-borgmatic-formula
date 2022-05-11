# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_file = tplroot ~ '.config.file' %}
{%- from tplroot ~ "/map.jinja" import mapdata as borgmatic with context %}

include:
  - {{ sls_config_file }}

Borgmatic repository is initialized:
  cmd.run:
    - name: {{ "/root/.local/bin/" if not borgmatic.install_global }}borgmatic init --encryption {{ borgmatic.encryption }}
    - onchanges:
      - sls: {{ sls_config_file }}

borgmatic-service-running-service-running:
  service.running:
    - name: {{ borgmatic.lookup.service.name }}.timer
    - enable: True
    - require:
      - Borgmatic repository is initialized
