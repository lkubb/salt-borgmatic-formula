# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_file = tplroot ~ '.config.file' %}
{%- from tplroot ~ "/map.jinja" import mapdata as borgmatic with context %}

{%- if salt["pillar.get"](borgmatic.lookup.ssh_key_pillar) %}

Borg SSH key is setup:
  file.managed:
    - name: {{ salt["user.info"]("root").home | path_join(".ssh", "id_borg") }}
    - contents_pillar: {{ borgmatic.lookup.ssh_key_pillar }}
    - user: root
    - group: {{ borgmatic.lookup.rootgroup }}
    - mode: '0600'
    - dir_mode: '0700'
    - makedirs: true

Borg SSH key is default:
  file.prepend:
    - name: {{ salt["user.info"]("root").home | path_join(".ssh", "config") }}
    - text: IdentityFile ~/.ssh/id_borg
    - require:
      - Borg SSH key is setup
{%- endif %}

{%- if borgmatic.known_hosts %}

Borg hosts are known:
  ssh_known_hosts.present:
    - names:
{%-   for name, config in borgmatic.known_hosts.items() %}
      - {{ name }}:
{%-     for conf, val in config.items() %}
        - {{ conf }}: {{ val }}
{%-     endfor %}
{%-   endfor %}
    - user: root
{%- endif %}
