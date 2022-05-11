# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_file = tplroot ~ '.config.file' %}
{%- from tplroot ~ "/map.jinja" import mapdata as borgmatic with context %}

{%- if salt["pillar.get"](borgmatic.lookup.ssh_key_pillar) %}

Borg SSH key is not default:
  file.replace:
    - name: {{ salt["user.info"]("root").home | path_join(".ssh", "config") }}
    - pattern: {{ 'IdentityFile ~/.ssh/id_borg' | regex_escape }}
    - repl: ''

Borg SSH key is absent:
  file.absent:
    - name: {{ salt["user.info"]("root").home | path_join(".ssh", "id_borg") }}
{%- endif %}

{%- if borgmatic.known_hosts %}

Borg hosts are unknown:
  ssh_known_hosts.absent:
    - names:
{%-   for name in borgmatic.known_hosts %}
      - {{ name }}
{%-   endfor %}
    - user: root
{%- endif %}
