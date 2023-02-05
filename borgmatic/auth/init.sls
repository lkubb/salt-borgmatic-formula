# vim: ft=sls

{#-
    Manages SSH secrets and known hosts.

    If you use my `Borg formula <https://github.com/lkubb/salt-borg-formula>`_,
    you might be better off using its ``borg.client`` state instead.
#}

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_file = tplroot ~ '.config.file' %}
{%- from tplroot ~ "/map.jinja" import mapdata as borgmatic with context %}

{%- if borgmatic.lookup.ssh_key_pillar and salt["pillar.get"](borgmatic.lookup.ssh_key_pillar) %}

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

{%- set borg_servers = salt["mine.get"]("borg_role:server", "ssh.host_keys", tgt_type="pillar") %}

{%- if borgmatic.known_hosts or borg_servers %}

Borg hosts are known:
  ssh_known_hosts.present:
    - names:
{%-   for name, config in borgmatic.known_hosts.items() %}
      - {{ name }}:
{%-     for conf, val in config.items() %}
        - {{ conf }}: {{ val }}
{%-     endfor %}
{%-   endfor %}
{%-   for minion, keys in borg_servers.items() %}
{%-     set minion_ip = salt["mine.get"](minion, "default_addrs")[minion][0] | default(false) %}
{%-     if minion_ip %}
{%-       for key in keys.values() %}
{%-         if "ssh-ed25519" in key %}
{%-           set key_type, key_val = key.split(maxsplit=1) %}
        - {{ minion_ip }}:
          - enc: {{ key_type }}
          - key: {{ key_val.split()[0] }}
{%-         endif %}
{%-       endfor %}
{%-     endif %}
{%-   endfor %}
    - user: root
{%- endif %}
