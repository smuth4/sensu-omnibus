#
# Cookbook Name:: freebsd
# Recipe:: portsnap
#
# Copyright 2013-2016, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

if node['platform'] == 'freebsd'
  case node['platform_version'].split(".").first
  when /11/
    portsnap_bin = 'portsnap'
    portsnap_options = '--interactive'
  when /10/
    package "gcc"

    portsnap_bin = 'portsnap'
    portsnap_options = '--interactive'
  else
    portsnap_bin = File.join(Chef::Config[:file_cache_path], 'portsnap')
    portsnap_options = ''

    # The sed forces portsnap to run non-interactively
    # fetch downloads a ports snapshot, extract puts them on disk (long)
    # update will update an existing ports tree
    s = script 'create non-interactive portsnap' do
      interpreter 'sh'
      code <<-EOS
        set -e # ensure we exit at first non-zero
        sed -e 's/\\[ ! -t 0 \\]/false/' /usr/sbin/portsnap > #{portsnap_bin}
        chmod +x #{portsnap_bin}
      EOS
      not_if { File.exist?(portsnap_bin) }
      action(node['freebsd']['compiletime_portsnap'] ? :nothing : :run)
    end
    s.run_action(:run) if node['freebsd']['compiletime_portsnap']
  end

  # Ensure we have a ports tree
  unless File.exist?('/usr/ports/.portsnap.INDEX')
    e = execute "#{portsnap_bin} #{portsnap_options} fetch extract".strip do
      live_stream(true)
      action(node['freebsd']['compiletime_portsnap'] ? :nothing : :run)
    end
    e.run_action(:run) if node['freebsd']['compiletime_portsnap']
  end

  e = execute "#{portsnap_bin} update #{portsnap_options}".strip do
    live_stream(true)
    action(node['freebsd']['compiletime_portsnap'] ? :nothing : :run)
  end
  e.run_action(:run) if node['freebsd']['compiletime_portsnap']
end
