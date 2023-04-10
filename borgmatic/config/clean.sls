# vim: ft=sls

{#-
    Removes the configuration of the borgmatic service and has a
    dependency on `borgmatic.service.clean`_.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_service_clean = tplroot ~ ".service.clean" %}
{%- from tplroot ~ "/map.jinja" import mapdata as borgmatic with context %}

include:
  - {{ sls_service_clean }}

Borgmatic configuration is absent:
  file.absent:
    - name: {{ borgmatic.lookup.config }}
    - require:
      - sls: {{ sls_service_clean }}
