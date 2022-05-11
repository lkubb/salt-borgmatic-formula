# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as borgmatic with context %}

borgmatic-service-clean-service-dead:
  service.dead:
    - name: {{ borgmatic.lookup.service.name }}.timer
    - enable: False
