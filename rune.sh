#!/bin/bash

run() {
  $@
  if [ $? -ne 0 ]; then
    exit 1
  fi  
}

BASE_DIR=$HOME/rune

rm -rf $BASE_DIR

which virtualenv

if [ $? -ne 0 ]; then
  echo '"virualenv" command not exist. If your os is ubuntu or debian, please run below command:'
  echo '  apt-get install python-pip'
  exit 1
fi

if [[ ! -a $BASE_DIR ]]; then
  echo 'Create directory: src'
  mkdir -p $BASE_DIR/src
fi

run virtualenv $BASE_DIR
run . $BASE_DIR/bin/activate

# easy_install pip==1.2.1
# pip freeze --local | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 pip install -U
# pip install --upgrade pip

# git clone https://github.com/openstack/keystone $BASE_DIR/src
run cp -rf $HOME/git/keystone $BASE_DIR/src

run cd $BASE_DIR/src/keystone
run python setup.py build
run python setup.py install

run pip install oslo.i18n oslo.log oslo.messaging osprofiler oslo.cache passlib \
  oslo.db

run mkdir -p $HOME/.keystone
run cp $BASE_DIR/src/keystone/etc/keystone-paste.ini \
  $HOME/.keystone/keystone.conf

# git clone https://github.com/openstack/python-keystoneclient $BASE_DIR/src
run cp -rf $HOME/git/python-keystoneclient $BASE_DIR/src

run cd $BASE_DIR/src/python-keystoneclient
run python setup.py build
run python setup.py install

# git clone https://github.com/openstack/keystoneauth $BASE_DIR/src
run cp -rf $HOME/git/keystoneauth $BASE_DIR/src

run cd $BASE_DIR/src/keystoneauth
run python setup.py build
run python setup.py install

run pip install jsonschema pycadf oauthlib pysaml2 oslo.policy

run keystone-wsgi-admin
