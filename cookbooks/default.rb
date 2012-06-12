include_recipe 'python'

package "libssl-dev" do
  action :install
end

%w(python-epoll pyOpenSSL pyapns).each do |name|
  python_pip name do
    action :install
  end
end

config       = node['pyapns']
service_name = config['service_name']

group_name = config['group']
user_name  = config['user']
home_dir   = config['home']

group group_name do
  system true
end

user user_name do
  gid     group_name
  home    home_dir
  comment "PyAPNS user"
  shell   "/bin/bash"
  system  true
end

directory home_dir do
  owner     user_name
  group     group_name
  recursive true
end
 
template "/etc/init/#{service_name}.conf" do
  source "service.conf.erb"
  mode   "0644"
  owner  "root"
  group  "root"
  variables({
    :port  => config['port'],
    :user  => config['user'],
    :group => config['group']
  })
end

service service_name do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :reload => true
  action   [:enable, :start]
end