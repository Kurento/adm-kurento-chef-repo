#
# Cookbook Name:: kurento
# Recipe:: default
#
# Copyright 2014, Kurento
#

include_recipe 'kurento::ubuntu-ppa'
include_recipe 'kurento::kms'
include_recipe 'kurento::kcs'