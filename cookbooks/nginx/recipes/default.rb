#
# Cookbook:: nginx
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
#

package "nginx"

service "nginx" do
    action [:enable, :start]
end

cookbook_file "/var/www/html/index.html" do
    source "index.html"
    mode "0644"
    action :create
end

template "/etc/nginx/conf.d/test.conf" do
    source "test.conf.erb"
    notifies :reload, "service[nginx]"
end
