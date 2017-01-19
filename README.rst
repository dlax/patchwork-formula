.. image:: https://travis-ci.org/dlax/patchwork-formula.svg?branch=master
    :target: https://travis-ci.org/dlax/patchwork-formula

=================
patchwork-formula
=================

A saltstack formula to install `patchwork`_.

Available states
================

.. contents::
    :local:

``patchwork``
-------------

Includes `install`, `user` and `config` state files.

``patchwork.install``
---------------------

Installs a patchwork application.

``patchwork.user``
------------------

Setup a dedicated user for patchwork.

``patchwork.config``
--------------------

Deploy settings for the patchwork application and installs its `cron` job.

``patchwork.gunicorn``
----------------------

Install gunicorn, supervisor and nginx to serve the patchwork application.

``patchwork.dbsetup``
---------------------

Initialize database and static files for the patchwork application.

.. _patchwork: http://jk.ozlabs.org/projects/patchwork/
