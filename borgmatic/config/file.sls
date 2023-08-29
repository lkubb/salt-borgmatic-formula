# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_package_install = tplroot ~ ".package.install" %}
{%- from tplroot ~ "/map.jinja" import mapdata as borgmatic with context %}
{%- from tplroot ~ "/libtofsstack.jinja" import files_switch with context %}

include:
  - {{ sls_package_install }}

{%- if borgmatic.config %}
{#-   Avoid creating an empty configuration file since it causes errors #}

Borgmatic configuration is managed:
  file.managed:
    - name: {{ borgmatic.lookup.config }}
    - source: {{ files_switch(
                    ["config.yaml", "config.yaml.j2"],
                    config=borgmatic,
                    lookup="Borgmatic configuration is managed",
                  )
               }}
    - mode: '0644'
    - user: root
    - group: {{ borgmatic.lookup.rootgroup }}
    - makedirs: true
    - template: jinja
    - require:
      - Borgmatic is installed
    - context:
        borgmatic: {{ borgmatic | json }}
{%- endif %}

{%- if borgmatic.config_d %}

Borgmatic multi-configuration is managed:
  file.managed:
    - names:
{%-   for name, config in borgmatic.config_d.items() %}
      - {{ borgmatic.lookup.paths.config_d | path_join(name ~ ".yaml") }}:
          - context:
              config: {{ config | json }}
{%-   endfor %}
    - source: {{ files_switch(
                    ["config_d.yaml.j2"],
                    config=borgmatic,
                    lookup="Borgmatic multi-configuration is managed",
                  )
               }}
    - template: jinja
    - mode: '0600'
    - user: root
    - group: {{ borgmatic.lookup.rootgroup }}
    - makedirs: true
    - require:
      - Borgmatic is installed
    - default_context:
        borgmatic: {{ borgmatic | json }}
{%- endif %}

{%- if borgmatic.config_d_common %}

Borgmatic multi-configuration includes are managed:
  file.managed:
    - names:
{%-   for name, config in borgmatic.config_d_common.items() %}
      - {{ borgmatic.lookup.paths.config_d | path_join("common", name ~ ".yaml") }}:
          - context:
              config: {{ config | json }}
{%-   endfor %}
    - source: {{ files_switch(
                    ["config_d.yaml.j2"],
                    config=borgmatic,
                    lookup="Borgmatic multi-configuration includes are managed",
                  )
               }}
    - template: jinja
    - mode: '0600'
    - user: root
    - group: {{ borgmatic.lookup.rootgroup }}
    - makedirs: true
    - require:
      - Borgmatic is installed
    - default_context:
        borgmatic: {{ borgmatic | json }}
{%- endif %}

Borgmatic scripts are synced:
  file.recurse:
    - name: {{ borgmatic.lookup.scripts }}
    - source: {{ files_switch(
                    ["scripts"],
                    config=borgmatic,
                    lookup="Borgmatic scripts are synced",
                  )
               }}
    - file_mode: '0755'
    - dir_mode: '0755'
    - user: root
    - group: {{ borgmatic.lookup.rootgroup }}
    - makedirs: true
    - clean: true
    - exclude_pat:
      - .gitkeep
    - require:
      - Borgmatic is installed

# Supporting services can be helpful to segment permissions,
# especially with SELinux. They can be specified in `Wants`
# to run before and should be `Type=oneshot`.
Borgmatic supporting services are synced:
  file.recurse:
    - name: {{ borgmatic.lookup.service.supporting_dir }}
    - source: {{ files_switch(
                    ["services"],
                    config=borgmatic,
                    lookup="Borgmatic supporting services are synced",
                  )
               }}
    - template: jinja
    - file_mode: '0644'
    - dir_mode: '0755'
    - user: root
    - group: {{ borgmatic.lookup.rootgroup }}
    - makedirs: true
    - exclude_pat:
      - .gitkeep
    - require:
      - Borgmatic is installed
    - context:
        borgmatic: {{ borgmatic | json }}
