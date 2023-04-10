# vim: ft=sls

{#-
    Stops/disables the borgmatic timer.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as borgmatic with context %}

Borgmatic timer is disabled:
  service.dead:
    - name: {{ borgmatic.lookup.service.name }}.timer
    - enable: false
