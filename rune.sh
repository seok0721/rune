#!/bin/bash

run() {
  echo "# RUN: $@"
  $@
  if [ $? -ne 0 ]; then
    echo "# RUN: Failed to run \"$@\""
    exit 1
  fi
}


# Initialize environment variable
BASE_DIR=$HOME/rune
# NOVA_USER=nova
# NOVA_DBPASS=8a0a1a5260a0d2a2006b
NOVA_USER=root
NOVA_DBPASS=0000
export OS_TOKEN=0000
export OS_URL=http://127.0.0.1:35357/v3

# Install chrony server
run sudo apt-get install chrony
run service chrony restart

# Check virtual command
run which virtualenv

if [ $? -ne 0 ]; then
  echo '"virualenv" command not exist. If your os is ubuntu or debian, please run below command:'
  echo '  apt-get install python-pip'
  exit 1
fi

# Check base directory
if [[ -a $BASE_DIR ]]; then
  echo 'Already base directory exists: "$BASE_DIR"'
fi

mkdir -p $BASE_DIR/src

# Make and activate virtual environment
run virtualenv $BASE_DIR
run . $BASE_DIR/bin/activate

# Install dependancy packages
run pip install oslo.i18n oslo.log oslo.messaging osprofiler oslo.cache \
  passlib oslo.db jsonschema pycadf oauthlib oslo.policy keystonemiddleware \
  oslo.versionedobjects oslo.reports eventlet warlock castellan microversion_parse \
  paramiko lxml os_brick libvirt-python oslo.rootwrap MySQL-python
run pip install pysaml2==4.0.2
run pip install oslo.context==2.5.0

# Install openstack client
run cd $BASE_DIR/src
# run git clone https://github.com/openstack/python-openstackclient
run cp -rf $HOME/git/python-openstackclient $BASE_DIR/src
run cd $BASE_DIR/src/python-openstackclient
run python setup.py build
run python setup.py install

# Install keystone
run cd $BASE_DIR/src
# run git clone https://github.com/openstack/keystone
run cp -rf $HOME/git/keystone $BASE_DIR/src
run cd $BASE_DIR/src/keystone
run python setup.py build
run python setup.py install

# Install keystone client
run cd $BASE_DIR/src
# run git clone https://github.com/openstack/python-keystoneclient
run cp -rf $HOME/git/python-keystoneclient $BASE_DIR/src
run cd $BASE_DIR/src/python-keystoneclient
run python setup.py build
run python setup.py install

# Install keystone auth
run cd $BASE_DIR/src
# run git clone https://github.com/openstack/keystoneauth
run cp -rf $HOME/git/keystoneauth $BASE_DIR/src
run cd $BASE_DIR/src/keystoneauth
run python setup.py build
run python setup.py install

# Install glanceclient
run cd $BASE_DIR/src
# run git clone https://github.com/openstack/python-glanceclient
run cp -rf $HOME/git/python-glanceclient $BASE_DIR/src/python-glanceclient
run cd $BASE_DIR/src/python-glanceclient
run python setup.py build
run python setup.py install

# Install cinderclient
run cd $BASE_DIR/src
# run git clone https://github.com/openstack/python-cinderclient
run cp -rf $HOME/git/python-cinderclient $BASE_DIR/src/python-cinderclient
run cd $BASE_DIR/src/python-cinderclient
run python setup.py build
run python setup.py install

# Install novaclient
run cd $BASE_DIR/src
# run git clone https://github.com/openstack/python-novaclient
run cp -rf $HOME/git/python-novaclient $BASE_DIR/src/python-novaclient
run cd $BASE_DIR/src/python-novaclient
run python setup.py build
run python setup.py install

# Install nova
run cd $BASE_DIR/src
# run git clone https://github.com/openstack/nova
run cp -rf $HOME/git/nova $BASE_DIR/src/nova
run cd $BASE_DIR/src/nova
run python setup.py build
run python setup.py install

# Install keystone configuration
run mkdir -p $HOME/.keystone
run cp $BASE_DIR/src/keystone/etc/* $HOME/.keystone
# run cp $BASE_DIR/.keystone/keystone.conf.sample $HOME/.keystone/keystone.conf

# Sync keystone database
run keystone-manage db_sync

# Init keystone database
echo "CREATE DATABASE IF NOT EXISTS keystone" | mysql -uroot -p0000
echo "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '$KEYSTONE_DBPASS'" | mysql -uroot -p0000
echo "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '$KEYSTONE_DBPASS'" | mysql -uroot -p0000

# Init nova database
echo "CREATE DATABASE IF NOT EXISTS nova_api" | mysql -uroot -p0000
echo "CREATE DATABASE IF NOT EXISTS nova" | mysql -uroot -p0000
echo "GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' IDENTIFIED BY '$NOVA_DBPASS'" | mysql -uroot -p0000
echo "GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' IDENTIFIED BY '$NOVA_DBPASS'" | mysql -uroot -p0000
echo "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY '$NOVA_DBPASS'" | mysql -uroot -p0000
echo "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY '$NOVA_DBPASS'" | mysql -uroot -p0000

# Run keystone server
# run keystone-wsgi-admin
