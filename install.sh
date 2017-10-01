#!/bin/bash

export FACTER_project_path
export FACTER_domain
export owncloud_admin_pass

while getopts ":a:p:d:" arg; do
  case $arg in
    d) FACTER_domain=${OPTARG}
      ;;
    p) FACTER_project_path=${OPTARG}
      ;;
    a) owncloud_admin_pass=${OPTARG}
      ;;
    *) echo 'Unknown option'
      exit 1
      ;;
  esac
done

OS_MAJ_VERSION=$(rpm -qa \*-release | grep -Ei "centos" | cut -d"-" -f3)
[[ -z "$OS_MAJ_VERSION" ]] && { echo "Distro not supported"; exit 1;}
yum install -y https://yum.puppetlabs.com/puppetlabs-release-pc1-el-"$OS_MAJ_VERSION".noarch.rpm
yum install -y puppet

export PATH=/opt/puppetlabs/puppet/bin:${PATH}
bash gen-env-files.sh ${owncloud_admin_pass}
gem install  librarian-puppet
LIBRARIAN_PUPPET_PATH=/opt/puppetlabs/modules LIBRARIAN_PUPPET_TMP=/opt/puppetlabs/tmp librarian-puppet install --verbose
puppet apply --modulepath /opt/puppetlabs/modules default.pp
