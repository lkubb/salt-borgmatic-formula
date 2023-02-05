# vim: ft=sls

{#-
    *Meta-state*.

    Undoes everything performed in the ``borgmatic`` meta-state
    in reverse order, i.e.
    removes borg SSH configuration,
    stops the service,
    removes the configuration file and then
    uninstalls the package.
#}

include:
  - .auth.clean
  - .service.clean
  - .config.clean
  - .package.clean
