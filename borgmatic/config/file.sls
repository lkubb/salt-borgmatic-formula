# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_package_install = tplroot ~ ".package.install" %}
{%- from tplroot ~ "/map.jinja" import mapdata as borgmatic with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

include:
  - {{ sls_package_install }}

Borgmatic configuration is managed:
  file.managed:
    - name: {{ borgmatic.lookup.config }}
    - source: {{ files_switch(["config.yaml", "config.yaml.j2"],
                              lookup="Borgmatic configuration is managed"
                  )
               }}
    - mode: '0644'
    - user: root
    - group: {{ borgmatic.lookup.rootgroup }}
    - makedirs: true
    - template: jinja
    - require:
      - sls: {{ sls_package_install }}
    - context:
        borgmatic: {{ borgmatic | json }}
