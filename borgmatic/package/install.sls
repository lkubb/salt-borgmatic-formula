# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as borgmatic with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

Borgmatic required packages are installed:
  pkg.installed:
    - pkgs: {{ borgmatic.lookup.pkg.reqs | json }}

Borgmatic is installed:
  pip.installed:
    - name: {{ borgmatic.lookup.pkg.name }}
    - user: root
    - upgrade: {{ borgmatic.autoupdate | to_bool }}
{%- if not borgmatic.install_global %}
    - extra_args:
      - --user
{%- endif %}

Borgmatic service is installed:
  file.managed:
    - name: {{ borgmatic.lookup.service.unit.format(name=borgmatic.lookup.service.name) }}
    - source: {{ files_switch(['borgmatic.service.j2'],
                              lookup='Borgmatic service is installed'
                 )
              }}
    - template: jinja
    - context:
        borgmatic: {{ borgmatic | json }}
    - user: root
    - group: {{ borgmatic.lookup.rootgroup }}
    - mode: '0644'

Borgmatic timer is installed:
  file.managed:
    - name: {{ borgmatic.lookup.service.timer.format(name=borgmatic.lookup.service.name) }}
    - source: {{ files_switch(['borgmatic.timer.j2'],
                              lookup='Borgmatic timer is installed'
                 )
              }}
    - template: jinja
    - context:
        borgmatic: {{ borgmatic | json }}
    - user: root
    - group: {{ borgmatic.lookup.rootgroup }}
    - mode: '0644'
