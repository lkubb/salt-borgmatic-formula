# vim: ft=sls

{#-
    *Meta-state*.

    This installs the borgmatic package,
    manages the borgmatic configuration file
    and then starts the associated borgmatic service.
#}

include:
  - .package
  - .config
  - .service
  - .auth
