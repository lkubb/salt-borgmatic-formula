# vim: ft=sls

{#-
    Removes the borgmatic package.
    Has a dependency on `borgmatic.config.clean`_.
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
{%-   set pip =
        salt["cmd.which_bin"](["/bin/pip3", "/usr/bin/pip3", "/bin/pip", "/usr/bin/pip"]) or
        '__slot__:salt:cmd.which_bin(["/bin/pip3", "/usr/bin/pip3", "/bin/pip", "/usr/bin/pip"])'
%}
  pip.removed:
    - name: {{ borgmatic.lookup.pkg.name }}
    - user: root
    # onedir/relenv breaks this otherwise
    - bin_env: {{ pip }}
{%- endif %}
