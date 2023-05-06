# vim: ft=sls

{#-
    Removes the borgmatic package.
    Has a depency on `borgmatic.config.clean`_.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_config_clean = tplroot ~ ".config.clean" %}
{%- from tplroot ~ "/map.jinja" import mapdata as borgmatic with context %}

include:
  - {{ sls_config_clean }}

Borgmatic is removed:
  file.absent:
    - names:
      - {{ borgmatic.lookup.service.unit.format(name=borgmatic.lookup.service.name) }}
      - {{ borgmatic.lookup.service.timer.format(name=borgmatic.lookup.service.name) }}
{%- if borgmatic.install == "venv" %}
      - {{ borgmatic.lookup.paths.install }}
      - {{ borgmatic.lookup.paths.bin }}
{%- else %}
  pip.removed:
    - name: {{ borgmatic.lookup.pkg.name }}
    - user: root
    # onedir/relenv breaks this otherwise
    - bin_env: __slot__:salt:cmd.run_stdout("command -v pip")
{%-   if not borgmatic.install_global %}
    - install_options:
      - --user
{%-   endif %}
{%- endif %}
