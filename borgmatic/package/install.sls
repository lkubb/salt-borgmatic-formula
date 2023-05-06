# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as borgmatic with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

Borgmatic required packages are installed:
  pkg.installed:
    - pkgs: {{ borgmatic.lookup.pkg.reqs | json }}

{%- if borgmatic.install == "venv" %}

Borgmatic is installed:
  virtualenv.managed:
    - name: {{ borgmatic.lookup.paths.install }}
    - python: python3
    - pip_upgrade: {{ "latest" == borgmatic.version }}
    - pip_pkgs:
{%-   if "latest" != borgmatic.version %}
      - borgmatic=={{ version }}
{%-   else %}
      - borgmatic
{%-   endif %}
{%-   for pkg in borgmatic.pip_pkgs %}
      - {{ pkg }}
{%-   endfor %}
  file.symlink:
    - name: {{ borgmatic.lookup.paths.bin }}
    - target: {{ borgmatic.lookup.paths.install | path_join("bin", "borgmatic") }}
    - require:
      - virtualenv: {{ borgmatic.lookup.paths.install }}
{%- else %}

Borgmatic is installed:
  pip.installed:
    - name: {{ borgmatic.lookup.pkg.name }}
    # onedir/relenv breaks this otherwise
    - bin_env: __slot__:salt:cmd.run_stdout("command -v pip")
    - user: root
    - upgrade: {{ borgmatic.get("autoupdate", borgmatic.version == "latest") | to_bool }}
{%-   if not borgmatic.install_global %}
    - extra_args:
      - --user
{%-   endif %}
{%- endif %}

Borgmatic service is installed:
  file.managed:
    - name: {{ borgmatic.lookup.service.unit.format(name=borgmatic.lookup.service.name) }}
    - source: {{ files_switch(["borgmatic.service.j2"],
                              lookup="Borgmatic service is installed"
                 )
              }}
    - template: jinja
    - context:
        borgmatic: {{ borgmatic | json }}
    - user: root
    - group: {{ borgmatic.lookup.rootgroup }}
    - mode: '0644'
    - require:
      - Borgmatic is installed

Borgmatic timer is installed:
  file.managed:
    - name: {{ borgmatic.lookup.service.timer.format(name=borgmatic.lookup.service.name) }}
    - source: {{ files_switch(["borgmatic.timer.j2"],
                              lookup="Borgmatic timer is installed"
                 )
              }}
    - template: jinja
    - context:
        borgmatic: {{ borgmatic | json }}
    - user: root
    - group: {{ borgmatic.lookup.rootgroup }}
    - mode: '0644'
    - require:
      - Borgmatic is installed
