# vim: ft=yaml
---
borgmatic:
  lookup:
    master: template-master
    # Just for testing purposes
    winner: lookup
    added_in_lookup: lookup_value
    config: '/etc/borgmatic/config.yaml'
    pkg:
      name: borgmatic
      reqs:
        - borgbackup
        - python3
        - python3-pip
    scripts: /opt/borgmatic/scripts
    service:
      name: borgmatic
      timer: /etc/systemd/system/{name}.timer
      unit: /etc/systemd/system/{name}.service
    ssh_key_pillar: borgmatic_secrets:ssh
  autoupdate: true
  config: {}
  encryption: none
  install_global: false
  known_hosts: {}
  service:
    rand_delay: 3h
    timer: daily

  tofs:
    # The files_switch key serves as a selector for alternative
    # directories under the formula files directory. See TOFS pattern
    # doc for more info.
    # Note: Any value not evaluated by `config.get` will be used literally.
    # This can be used to set custom paths, as many levels deep as required.
    files_switch:
      - any/path/can/be/used/here
      - id
      - roles
      - osfinger
      - os
      - os_family
    # All aspects of path/file resolution are customisable using the options below.
    # This is unnecessary in most cases; there are sensible defaults.
    # Default path: salt://< path_prefix >/< dirs.files >/< dirs.default >
    #         I.e.: salt://borgmatic/files/default
    # path_prefix: template_alt
    # dirs:
    #   files: files_alt
    #   default: default_alt
    # The entries under `source_files` are prepended to the default source files
    # given for the state
    # source_files:
    #   borgmatic-config-file-file-managed:
    #     - 'example_alt.tmpl'
    #     - 'example_alt.tmpl.jinja'

    # For testing purposes
    source_files:
      borgmatic-config-file-file-managed:
        - 'example.tmpl.jinja'

  # Just for testing purposes
  winner: pillar
  added_in_pillar: pillar_value
