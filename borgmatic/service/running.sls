# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_config_file = tplroot ~ ".config.file" %}
{%- from tplroot ~ "/map.jinja" import mapdata as borgmatic with context %}
{%- set borgmatic_bin = borgmatic.lookup.paths.bin %}
{%- if borgmatic.install != "venv" and not borgmatic.install_global %}
{%-   set borgmatic_bin = "/root/.local/bin/borgmatic" %}
{%- endif %}

include:
  - {{ sls_config_file }}

Borgmatic repository is initialized:
  cmd.run:
    - name: {{ borgmatic_bin }} init --encryption {{ borgmatic.encryption }}
    - onchanges:
      - sls: {{ sls_config_file }}

Borgmatic timer is enabled:
  service.running:
    - name: {{ borgmatic.lookup.service.name }}.timer
    - enable: true
    - require:
      - Borgmatic repository is initialized

# It seems the binary has to be invoked at least once from outside
# the service to initialize /root/.borgmatic @TODO
# At least on RedHat.
