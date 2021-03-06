lang en_US.UTF-8
keyboard us
timezone --utc Etc/UTC
auth --enableshadow --passalgo=sha512
selinux --permissive
rootpw --lock
user --name=node --lock
firstboot --disabled
services --enabled=ssh
poweroff

clearpart --all --initlabel
bootloader --timeout=1
# Size needs to be something smaller than the disk size, grow ensures that the whole disk is used
part / --size=2048 --grow --fstype=ext4 --fsoptions=discard

%packages --ignoremissing
cloud-init
initial-setup
%end


#
# CentOS repositories
#
url --mirrorlist=http://mirrorlist.centos.org/?repo=os&release=$releasever&arch=$basearch
repo --name=updates --mirrorlist=http://mirrorlist.centos.org/?repo=updates&release=$releasever&arch=$basearch
repo --name=extra --mirrorlist=http://mirrorlist.centos.org/?repo=extras&release=$releasever&arch=$basearch

#url --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever&arch=$basearch
#repo --name=updates --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f$releasever&arch=$basearch

#
# Adding upstream oVirt
#
%post --erroronfail
set -x
grep -i fedora /etc/system-release && yum-config-manager --add-repo="http://download.gluster.org/pub/gluster/glusterfs/LATEST/Fedora/glusterfs-fedora.repo"
grep -i centos /etc/system-release && yum-config-manager --add-repo="http://download.gluster.org/pub/gluster/glusterfs/LATEST/CentOS/glusterfs-epel.repo"
yum install -y http://plain.resources.ovirt.org/pub/yum-repo/ovirt-release-master.rpm
yum install -y ovirt-engine

#
echo "Creating a partial answer file"
#
cat > /root/ovirt-engine-answers <<__EOF__
[environment:default]
OVESETUP_CORE/engineStop=none:None
OVESETUP_DIALOG/confirmSettings=bool:True
OVESETUP_DB/database=str:engine
OVESETUP_DB/fixDbViolations=none:None
OVESETUP_DB/secured=bool:False
OVESETUP_DB/securedHostValidation=bool:False
OVESETUP_DB/host=str:localhost
OVESETUP_DB/user=str:engine
OVESETUP_DB/port=int:5432
OVESETUP_ENGINE_CORE/enable=bool:True
OVESETUP_SYSTEM/nfsConfigEnabled=bool:False
OVESETUP_SYSTEM/memCheckEnabled=bool:False
OVESETUP_CONFIG/applicationMode=str:virt
OVESETUP_CONFIG/firewallManager=str:firewalld
OVESETUP_CONFIG/storageType=str:nfs
OVESETUP_CONFIG/sanWipeAfterDelete=bool:False
OVESETUP_CONFIG/updateFirewall=bool:True
OVESETUP_CONFIG/websocketProxyConfig=bool:True
OVESETUP_PROVISIONING/postgresProvisioningEnabled=bool:True
OVESETUP_APACHE/configureRootRedirection=bool:True
OVESETUP_APACHE/configureSsl=bool:True
OSETUP_RPMDISTRO/requireRollback=none:None
OSETUP_RPMDISTRO/enableUpgrade=none:None
__EOF__

%end
