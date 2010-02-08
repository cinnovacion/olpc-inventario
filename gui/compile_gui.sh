#!/bin/bash
# Maintainer: Mauricio Rodriguez A.

# compile GUI
gui_dir=$(dirname $0)
test -d ../public/build && rm -rf ../public/build 
cd $gui_dir; ./generate.py build && mv build ../public


# if we are using SELinux, set the correct context for the newly created GUI files
SELINUXENABLED_CMD=selinuxenabled

which $SELINUXENABLED_CMD > /dev/null 2>&1
ret=$?

if [ $ret -eq 0 ] ; then 
  selinuxenabled
  ret=$?
  if [ $ret -eq 0 ] ; then
    chcon -R -h -t httpd_sys_content_t ../public/build
  fi
fi


