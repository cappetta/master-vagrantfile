# master-vagrantfile
A Simple repository for using, building, &amp; maintaining my vagrantfile customizations (e.g. ruby code)

Since the index of add-on logic is small I am placing the code snippets below.

## Logic to handle plugin dependencies
```
unless Vagrant.has_plugin?("vagrant-docker-compose")
  system("vagrant plugin install vagrant-docker-compose")
  puts "Dependencies installed, please try the command again."
  exit
end
```


## Logic to detect the Operating System
```
module OS
    def OS.windows?
        (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
    end

    def OS.mac?
        (/darwin/ =~ RUBY_PLATFORM) != nil
    end

    def OS.unix?
        !OS.windows?
    end

    def OS.linux?
        OS.unix? and not OS.mac?
    end
end
```

## If windows do not install the RSYNC plugin
```
if OS.windows?
    puts "Vagrant launched from windows."
else
    puts "Vagrant launched from mac."
    unless Vagrant.has_plugin?("vagrant-gatling-rsync")
      system("vagrant plugin install vagrant-gatling-rsync")
      puts "Rsync Dependency installed, please try the command again."
    end
end
```

## Leverage YAML file for dynamic declarations
```
require 'yaml'
nodes = YAML.load_file("./yaml/vagrant.yaml")
```

## Using YAML create dynamic logic for provisioning 1-to-many folder mounting.
This is very helpful when you want to mount/share content
```
unless node['folders'].nil?
      node['folders'].each do |folder|
        node_config.vm.synced_folder folder['local'], folder['virtual']
      end
end
```

## Using YAML create dynamic logic for provisioning 1-to-many folder mounting.
```
unless node["initScript"].nil?
      node["initScript"].each do |script|
        node_config.vm.provision :shell, path: script["init"], privileged: true
end
```

## Using YAML to iterate through node build configs for key configs on Openstack
```
 node_config.vm.provider :openstack do |os|
        os.keypair_name           = openstack['key']
        os.username               = openstack['username']
        os.password               = openstack['password']
        os.tenant_name            = openstack['tenant']
        os.flavor                 = node['flavor']
        os.image                  = node["box"]
        os.security_groups        = openstack['security_groups'] # SecGroups must be setup prior to usage
        os.openstack_auth_url     = "http://" + openstack['auth_url'] + ":5000/v2.0/tokens"      # e.g. "#{ENV['OS_AUTH_URL']}/tokens"
        os.networks               = openstack["tenant_network"]
        if defined? nodes["floatingip_pool"]
          os.floating_ip_pool	    = nodes["floatingip_pool"]
        else
             os.floating_ip	          = node["floating_ip"]
        end
 end
```

## Switch between users for different Operating Systems
```if node["box"] == 'centos-7' then
           node_config.ssh.username = "centos"
         elsif node["box"] == 'trusty64'
           node_config.ssh.username = "ubuntu"
         else
           node_config.ssh.username = "root"
         end
```

## Using YAML to setup forwarded ports (e.g. virtualbox)
```
    node["forwards"].each do |port|
        node_config.vm.network "forwarded_port", guest: port["guest"], host: port["host"], id: port["id"]
    end
```