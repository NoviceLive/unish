#!/usr/bin/env bash


#
# Copyright 2016 Gu Zhengxiong <rectigu@gmail.com>
#


_plugins_dir="${UNISH}/bundle"

_plugin_name=virtualenvwrapper
_plugin_entry="$_plugins_dir/$_plugin_name/$_plugin_name.sh"

export WORKON_HOME=${HOME}/.virtualenv
export PROJECT_HOME=${HOME}/repo/private
source_if_exists "$_plugin_entry"
