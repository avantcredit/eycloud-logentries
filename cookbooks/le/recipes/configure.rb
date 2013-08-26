#
# Cookbook Name:: le
# Recipe:: configure
#

execute "le init --account-key" do
  command "le init --account-key #{node[:le_api_key]}"
  action :run
  not_if { File.exists?('/etc/le/config') }
end

execute "echo ec2eu" do
  command "echo 'ec2eu=False' >> /etc/le/config"
  action :run
  only_if { File.exists?('/etc/le/config') }
end

execute "le register" do
  command "le register --name #{node[:applications].keys.first}"
  action :run
  not_if { File.exists?('/etc/le/config') } 
end

follow_paths = [
  "/var/log/syslog",
  "/var/log/auth.log",
  "/var/log/daemon.log"
]
(node[:applications] || []).each do |app_name, app_info|
  follow_paths << "/var/log/nginx/#{app_name}.access.log"
end

follow_paths.each do |path|
  execute "le follow #{path}" do
    command "le follow #{path}"
    ignore_failure true 
    action :run
  end
end
