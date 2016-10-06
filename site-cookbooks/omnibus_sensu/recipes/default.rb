#
# Cookbook Name:: omnibus_sensu
# Recipe:: default
#
# Copyright (c) 2016 Sensu, All Rights Reserved.

include_recipe "omnibus::default"

omnibus_build "sensu" do
  project_dir "/home/vagrant/sensu"
  log_level :internal
  environment({
    "SENSU_VERSION" => node["omnibus_sensu"]["build_version"],
    "BUILD_NUMBER" => node["omnibus_sensu"]["build_iteration"]
  })
end
