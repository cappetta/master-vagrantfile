#!/bin/sh

# a Derivitive of a script from Brian Cantoni
#
# Purpose: Provisioning several VMs at once can be pretty slow depending on the speed of
# both the System and the mirrors at the time. This script creates the 3 VMs in series, then
# provisions them in parallel using shell and puppet provisioning steps.
#
# source:
# http://joemiller.me/2012/04/26/speeding-up-vagrant-with-parallel-provisioning/
 
MAX_PROCS=4
 
parallel_shell_provision() {
    while read box; do
        echo "Shell Provisioning '$box'. Output will be in: $box.out.txt" 1>&2
        echo $box
    done | xargs -P $MAX_PROCS -I"BOXNAME" \
        sh -c 'vagrant provision --provision-with shell BOXNAME > /tmp/BOXNAME.out.txt 2>&1 || echo "Error Occurred: BOXNAME"' 
        #sh -c 'vagrant provision --provision-with puppet BOXNAME > /tmp/BOXNAME.out.txt 2>&1 || echo "Error Occurred: BOXNAME"'
}


parallel_puppet_provision() {
    while read box; do
        echo "Puppet Provisioning '$box'. Output will be in: $box.out.txt" 1>&2
        echo $box
    done | xargs -P $MAX_PROCS -I"BOXNAME" \
        sh -c 'vagrant provision --provision-with puppet BOXNAME >> /tmp/BOXNAME.out.txt 2>&1 || echo "Error Occurred: BOXNAME"' 
}

list_of_vms="vm1 vm2 vm3 vm4"

## start boxes sequentially to avoid vbox explosions (virtual box)
#vagrant destroy -f $agents
#vagrant up --no-provision --provider=openstack $agents

vagrant up --no-provision $list_of_vms

# but run provision tasks in parallel
cat <<EOF | parallel_shell_provision
Must
Specify
the name
of your VMS
here
EOF
#graphite
#grafana
#
cat <<EOF | parallel_puppet_provision
Must
Specify
the name
of your VMS
here
EOF


