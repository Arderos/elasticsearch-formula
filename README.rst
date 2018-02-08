================
elasticsearch-formula
================

This formula is a fork of `alias454's work <https://github.com/alias454/elasticsearch-formula>`_.

Here is the list of changes:
================

- The formula is now compatible with Debian-based distros
- It is now possible to create LVM structure and format the target volumes (disabled by default)
- Firewalld-related code was removed as I believe it is out of scope of this formula
- Sysctl-related code is simplified as Salt would automatically create override files by default
- Minimum master nodes is now 2 by default (configurable) and master role is set to true by default to facilitate correct cluster setup

A saltstack formula to manage elasticsearch 2.x and 5.x clusters on RHEL and Debian based systems.

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

Available states
================

.. contents::
    :local:

``es-repo``
------------
Manage repo file on RHEL/CentOS 7/Debian/Ubuntu systems.

``es-package``
------------
Install elasticsearch and additional prerequisite packages

``es-mount``
------------
Optionally configure non-statndard folders, create LVM PG/VG/LV and mount additional devices if used
 
``es-config``
------------
Manage configuration file placement

``es-kernel``
------------
Apply kernal tweaks and system tuning options

``es-service``
------------
Sets up the elasticsearch service and makes sure it is running on RHEL/CentOS 7/Debian/Ubuntu systems.
