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
    - names:
      - {{ borgmatic.lookup.config }}
{%-   for name, config in borgmatic.config_d.items() %}
      - {{ borgmatic.lookup.paths.config_d | path_join(name ~ ".yaml") }}
{%-   endfor %}
{%-   for name, config in borgmatic.config_d_common.items() %}
      - {{ borgmatic.lookup.paths.config_d | path_join("common", name ~ ".yaml") }}
{%-   endfor %}
      - {{ borgmatic.lookup.scripts }}
    - require:
      - sls: {{ sls_service_clean }}
