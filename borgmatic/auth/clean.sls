# vim: ft=sls

{#-
    Removes managed SSH secrets and known hosts.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_config_file = tplroot ~ ".config.file" %}
{%- from tplroot ~ "/map.jinja" import mapdata as borgmatic with context %}

{%- if salt["pillar.get"](borgmatic.lookup.ssh_key_pillar) %}

Borg SSH key is not default:
  file.replace:
    - name: {{ salt["user.info"]("root").home | path_join(".ssh", "config") }}
    - pattern: {{ "IdentityFile ~/.ssh/id_borg" | regex_escape }}
    - repl: ''

Borg SSH key is absent:
  file.absent:
    - name: {{ salt["user.info"]("root").home | path_join(".ssh", "id_borg") }}
{%- endif %}

{%- set borg_servers = salt["mine.get"]("borg_role:server", "ssh.host_keys", tgt_type="pillar") %}

{%- if borgmatic.known_hosts or borg_servers %}

Borg hosts are unknown:
  ssh_known_hosts.absent:
    - names:
{%-   for name in borgmatic.known_hosts %}
      - {{ name }}
{%-   endfor %}
{%-   for minion, keys in borg_servers.items() %}
{%-     set minion_ip = salt["mine.get"](minion, "default_addrs")[minion][0] | default(false) %}
{%-     if minion_ip %}
{%-       for key in keys.values() %}
{%-         if "ssh-ed25519" in key %}
        - {{ minion_ip }}
{%-         endif %}
{%-       endfor %}
{%-     endif %}
{%-   endfor %}
    - user: root
{%- endif %}
