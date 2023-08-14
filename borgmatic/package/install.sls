# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as borgmatic with context %}
{%- from tplroot ~ "/libtofsstack.jinja" import files_switch with context %}

{#- very crude onedir check – relenv pythonexecutable does not end with `run` #}
{%- set onedir = grains.pythonexecutable.startswith("/opt/saltstack") %}
{#- using slots for bin_env does not seem to work, causes fallback to salt-pip #}
{%- set pip =
      salt["cmd.which_bin"](["/bin/pip3", "/usr/bin/pip3", "/bin/pip", "/usr/bin/pip"]) or
      '__slot__:salt:cmd.which_bin(["/bin/pip3", "/usr/bin/pip3", "/bin/pip", "/usr/bin/pip"])'
%}

Borg is available:
  pkg.installed:
    - name: {{ borgmatic.lookup.pkg.reqs.borg }}
    - unless:
      # avoid failing if it's not in the repo and managed otherwise
      - fun: cmd.which
        cmd: borg

Borgmatic required packages are installed:
  pkg.installed:
    - pkgs:
      - {{ borgmatic.lookup.pkg.reqs.python }}
      - {{ borgmatic.lookup.pkg.reqs.pip }}

{%- if borgmatic.install == "venv" %}

Virtualenv is installed:
  pkg.installed:
    - name: {{ borgmatic.lookup.pkg.reqs.venv.pkg }}
  pip.installed:
    - name: {{ borgmatic.lookup.pkg.reqs.venv.pip }}
    - bin_env: {{ pip }}
    - onfail:
      - pkg: {{ borgmatic.lookup.pkg.reqs.venv.pkg }}
    - require:
      - Borgmatic required packages are installed

Borgmatic is installed:
  virtualenv.managed:
    - name: {{ borgmatic.lookup.paths.install }}
    - python: python3
    - pip_upgrade: {{ borgmatic.version == "latest" }}
    - pip_pkgs:
{%-   if borgmatic.version != "latest" %}
      - borgmatic=={{ version }}
{%-   else %}
      - borgmatic
{%-   endif %}
{%-   for pkg in borgmatic.pip_pkgs %}
      - {{ pkg }}
{%-   endfor %}
    - require_any:
      - pkg: {{ borgmatic.lookup.pkg.reqs.venv.pkg }}
      - pip: {{ borgmatic.lookup.pkg.reqs.venv.pip }}
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
    - bin_env: {{ pip }}
    - user: root
    - upgrade: {{ borgmatic.get("autoupdate", borgmatic.version == "latest") | to_bool }}
{%-   if not borgmatic.install_global %}
    - extra_args:
      - --user
{%-   endif %}
    - require:
      - Borgmatic required packages are installed
{%- endif %}

Borgmatic service is installed:
  file.managed:
    - name: {{ borgmatic.lookup.service.unit.format(name=borgmatic.lookup.service.name) }}
    - source: {{ files_switch(
                    ["borgmatic.service", "borgmatic.service.j2"],
                    config=borgmatic,
                    lookup="Borgmatic service is installed",
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
    - source: {{ files_switch(
                    ["borgmatic.timer", "borgmatic.timer.j2"],
                    config=borgmatic,
                    lookup="Borgmatic timer is installed",
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
