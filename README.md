# Devops Guild 1/10/2017 - Chef Demo

[Overview](https://docs.chef.io/chef_overview.html)

The Chef DK workstation is the location where users interact with Chef. On the workstation users author and test cookbooks using tools such as Test Kitchen and interact with the Chef server using the knife and chef command line tools.

Chef client nodes are the machines that are managed by Chef. The Chef client is installed on each node and is used to configure the node to its desired state.

The Chef server acts as a hub for configuration data. The Chef server stores cookbooks, the policies that are applied to nodes, and metadata that describes each registered node that is being managed by Chef. Nodes use the Chef client to ask the Chef server for configuration details, such as recipes, templates, and file distributions.

## Chef Repo

Every Chef installation needs a Chef Repository. This is the place where cookbooks, roles, config files and other artifacts for managing systems with Chef will live. We strongly recommend storing this repository in a version control system such as Git and treat it like source code.

While we prefer Git, and make this repository available via GitHub, you are welcome to download a tar or zip archive and use your favorite version control system to manage the code.

## Repository Directories

This repository contains several directories, and each directory contains a README file that describes what it is for in greater detail, and how to use it for managing your systems with Chef.

- `cookbooks/` - Cookbooks you download or create.
- `data_bags/` - Store data bags and items in .json in the repository.
- `roles/` - Store roles in .rb or .json in the repository.
- `environments/` - Store environments in .rb or .json in the repository.

## Cookbooks

[Overview](https://docs.chef.io/cookbooks.html)

A cookbook is the fundamental unit of configuration and policy distribution. A cookbook defines a scenario and contains everything that is required to support that scenario. It can ccontain the following directories:

- `recipes/` - Recipes that specify the resources to use and the order in which they are to be applied
- `attributes/` - Attribute values
- `files/` - File distributions
- `templates/` - Templates
- `resources/` - instructs chef-client to complete various tasks like installing packages, running ruby code
- `libraries/` - allows use of arbitrary Ruby code to extend chef-client

The chef-client uses Ruby as its reference language for creating cookbooks and defining recipes, with an extended DSL for specific resources. A reasonable set of resources are available to the chef-client, enough to support many of the most common infrastructure automation scenarios; however, this DSL can also be extended when additional resources and capabilities are required.

## Kitchen

Use Test Kitchen to automatically test cookbook data across any combination of platforms and test suites:

- Defined in a .kitchen.yml file. See the configuration documentation for options and syntax information.
- Uses a driver plugin architecture
- Supports cookbook testing across many cloud providers and virtualization technologies
- Supports all common testing frameworks that are used by the Ruby community
- Uses a comprehensive set of base images provided by Bento

## Demo

Install chef [here](https://downloads.chef.io/chefdk):

This also works:

```
$ brew cask install chefdk
```

Also install:
- Virtualbox [download](https://www.virtualbox.org/wiki/Downloads)
- Vagrant [download](https://www.vagrantup.com/downloads.html)

Generate a chef-repo ([docs](https://docs.chef.io/ctl_chef.html#chef-generate-repo)):
```bash
$ chef generate repo demo
```

Generate a cookbook ([docs](https://docs.chef.io/ctl_chef.html#chef-generate-cookbook)):
```
$ chef generate cookbook cookbooks/nginx
$ cd cookbooks/nginx
```

Update your .kitchen.yml:

```yml
driver:
  name: vagrant
  network:
    - ["forwarded_port", {guest: 80, host: 8080}]
```


Update `cookbooks/nginx/recipes/default.rb`:

```ruby
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
```

We are using the following chef resources:

- [package](https://docs.chef.io/resource_package.html)
- [service](https://docs.chef.io/resource_service.html)
- [cookbook_file](https://docs.chef.io/resource_cookbook_file.html)
- [template](https://docs.chef.io/resource_template.html)

Generate the file:

```
$ chef generate file index.html
```

And add the following content:

```html
<html>
    <head>
        <title>Hello</title>
    </head>
    <body>
        <h1>Hello, World!</h1>
    </body>
</html>
```

Generate default attributes:

```
$ chef generate attribute default
```
```
default['nginx']['listen'] = '80'
default['nginx']['root'] = '/var/www/html'
default['nginx']['server_name'] = 'localhost'
```

Generate the template:

```
$ chef generate template test.conf
```

and add the following content:

```erb
server {

  listen   <%= node['nginx']['listen'] %>;

  root <%= node['nginx']['root'] %>;
  index index.html index.htm;

  server_name <%= node['nginx']['server_name'] %>;
  
  location / {
   default_type "text/html";
   try_files $uri.html $uri $uri/ /index.html;
  }

}
```

Using kitchen:

```bash
$ kitchen create # create virtual machine(s)
$ kitchen converge # provision
$ kitchen exec # execute commands on machine
$ kitchen login # ssh into machine
$ kitchen destroy # cleanup
```

Add some automated testing to `test/smoke/default_test.rb`

```ruby
describe package('nginx') do
  it { should be_installed }
end

describe port(80) do
  it { should be_listening }
end

describe file('/var/www/html/index.html') do
 it { should exist }
end
```

and run:

```
$ kitchen verify
```
