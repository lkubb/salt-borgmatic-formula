Available states
----------------

The following states are found in this formula:

.. contents::
   :local:


``borgmatic``
^^^^^^^^^^^^^
*Meta-state*.

This installs the borgmatic package,
manages the borgmatic configuration file
and then starts the associated borgmatic service.


``borgmatic.package``
^^^^^^^^^^^^^^^^^^^^^
Installs the borgmatic package only.


``borgmatic.config``
^^^^^^^^^^^^^^^^^^^^
Manages the borgmatic service configuration.
Has a dependency on `borgmatic.package`_.


``borgmatic.service``
^^^^^^^^^^^^^^^^^^^^^
Enables/starts the borgmatic timer.
Has a dependency on `borgmatic.config`_.


``borgmatic.auth``
^^^^^^^^^^^^^^^^^^
Manages SSH secrets and known hosts.

If you use my `Borg formula <https://github.com/lkubb/salt-borg-formula>`_,
you might be better off using its ``borg.client`` state instead.


``borgmatic.clean``
^^^^^^^^^^^^^^^^^^^
*Meta-state*.

Undoes everything performed in the ``borgmatic`` meta-state
in reverse order, i.e.
removes borg SSH configuration,
stops the service,
removes the configuration file and then
uninstalls the package.


``borgmatic.package.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^^
Removes the borgmatic package.
Has a depency on `borgmatic.config.clean`_.


``borgmatic.config.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^
Removes the configuration of the borgmatic service and has a
dependency on `borgmatic.service.clean`_.


``borgmatic.service.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^^
Stops/disables the borgmatic timer.


``borgmatic.auth.clean``
^^^^^^^^^^^^^^^^^^^^^^^^
Removes managed SSH secrets and known hosts.


