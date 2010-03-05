# spec file for our tracking, monitoring and support web app
Name: inventario		
Version: 0.3
Release: 13
Vendor: Paraguay Educa
Summary: This (Ruby on Rails based) web app lets you track laptops given out, status of networks and support tickets.
Group:	Applications/Internet
License: GPL	
URL: http://git.paraguayeduca.org/gitweb/projects/inventario.git
Source0: %{name}-%{version}.tar.gz
BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
Requires: ruby(abi) = 1.8, crontabs, rubygems, rubygem-activesupport, rubygem-activeresource, rubygem-rails, mysql-server, htmldoc, httpd, ruby-mysql, ruby-json, rubygem-gruff, rubygem-spreadsheet-excel, rubygem-parseexcel, rubygem-gbarcode, logrotate, rubygem-gettext, rubygem-gettext_activerecord, rubygem-gettext_rails, rubygem-locale_rails
BuildArch: noarch

%description
This web application is meant to be use by deployments who need to track what laptop has been given to who (inventory), maintain a real-time status of the deployed wi-fi networks (monitoring) and register tickets of tech problems found (support). 

In order to use certain features (i.e.: monitoring) additional packages should be installed in schoolservers. 

%prep
%setup -q

%build
%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/var/%{name}
mkdir -p $RPM_BUILD_ROOT/etc/cron.d
cp extra/cron.d/* $RPM_BUILD_ROOT/etc/cron.d
mkdir -p $RPM_BUILD_ROOT/etc/logrotate.d
cp extra/inventario-logrotate $RPM_BUILD_ROOT/etc/logrotate.d/inventario
cp -r * $RPM_BUILD_ROOT/var/%{name}
test -d $RPM_BUILD_ROOT/var/%{name}/public/build && rm -rf $RPM_BUILD_ROOT/var/%{name}/public/build > /dev/null 2>&1
cd $RPM_BUILD_ROOT/var/%{name}/gui
# Qooxdoo no maneja links simbolicos :(
ln -s /usr/share/qooxdoo-sdk $RPM_BUILD_ROOT/var/%{name}/
./compile_gui.sh

# kill sym link de qooxdoo-sdk
rm $RPM_BUILD_ROOT/var/%{name}/qooxdoo-sdk

# kill gui compilation cache 
rm -rf $RPM_BUILD_ROOT/var/%{name}/gui/cache

# kill logs
rm -f $RPM_BUILD_ROOT/var/%{name}/log/*

# kill packaging 
rm -rf $RPM_BUILD_ROOT/var/%{name}/packaging

# kill migrations
#rm -f $RPM_BUILD_ROOT/var/%{name}/db/migrate/*

###
# NI idea porque no funciona esto (entonces no borro los migrations)
#
# copy migrations 
#cp db/migrate/20091006200434_create_spare_parts_registries.rb $RPM_BUILD_ROOT/var/%{name}/db/migrate/
#cp db/migrate/20091007202548_add_is_ghost_device_to_devices.rb $RPM_BUILD_ROOT/var/%{name}/db/migrate/


%clean
rm -rf $RPM_BUILD_ROOT

%post
# copy virtual-host-example-config to /etc/httpd/conf.d
if [ ! -f /etc/httpd/conf.d/101-tracking.conf ] ; then
  cp /var/%{name}/extra/101-tracking.conf /etc/httpd/conf.d/101-tracking.conf.example
fi

# update Rails stuff
cd /var/%{name}/ && rake rails:update

# copy database config template
cp /var/%{name}/config/database.yml.example /var/%{name}/config/database.yml

# try to create DB, if it doesnt exist
mysql -u root -e 'create database if not exists inventario;' > /dev/null 2>&1 || true

# load initial database
cd /var/%{name}
if [ -f /var/%{name}/config/database.yml ] ; then
  # initial tables def
  rake seed_data:install
  # migrations
  rake db:migrate
  # initial data
  rake seed_data:setup
  # idemptently fixes data errors (and cleanups) 
  rake seed_data:fix
else
  echo "No suitable database config file was found. You will have to create config/database.yml and then run rake seed_data:seed "
fi

%postun

%files
%defattr(-,root,root,-)
%dir /var/%{name}
/etc/cron.d
/etc/logrotate.d/inventario
/var/%{name}/extra
/var/%{name}/app
/var/%{name}/config
%attr(-,apache,apache) /var/%{name}/config/environment.rb
/var/%{name}/COPYING
/var/%{name}/db
/var/%{name}/doc
/var/%{name}/gui
/var/%{name}/lib
%attr(-,apache,apache) /var/%{name}/log
/var/%{name}/public
%attr(-,apache,apache) /var/%{name}/public/images
%attr(-,apache,apache) /var/%{name}/public/images/barcodes
/var/%{name}/Rakefile
/var/%{name}/INSTALL
/var/%{name}/script
/var/%{name}/test
%attr(-,apache,apache) /var/%{name}/tmp
/var/%{name}/translation
/var/%{name}/vendor

%changelog

* Fri Mar 05 2010 Raul Gutierrez S. <mabente@paraguayeduca.org>
- Qooxdoo 1.x doesnt handle repeated values in SelectBox. Added a hack around this. 

* Thu Mar 04 2010 Raul Gutierrez S. <mabente@paraguayeduca.org>
- Translations for the GUI side, deleted deprecated classes, cleaned up comments and indentation, lots of fixes here and there.

* Tue Mar 02 2010 Martin Abente <mabente@paraguayeduca.org>
- Ticket 349: enumerate list of laptop lendings

* Tue Mar 02 2010 Raul Gutierrez S. <rgs@paraguayeduca.org>
- Translated base strings to english in app/models/ and applied _(). Lots of code cleanup, indentation and comments cleanup and translation as well

* Sun Feb 21 2010 Raul Gutierrez S. <rgs@paraguayeduca.org>
- A few more strings translated. Testing to see if our git migration went ok. 
- Syntax error went through accidentally. 
- Unstable release with new (rake) translation tasks and lots of calls to _(). 

* Fri Feb 19 2010 Raul Gutierrez S. <rgs@paraguayeduca.org>
- Qooxdoos build job was re-defined in config.json (thus preventing the inclusion of the translation files). 

* Fri Feb 19 2010 Martin Abente <mabente@paraguayeduca.org>
- Ticket 530: Showing languages full text at login screen

* Thu Feb 18 2010 Martin Abente <mabente@paraguayeduca.org>
- Ticket 530: Runtime language selection

* Wed Feb 17 2010 Martin Abente <mabente@paraguayeduca.org>
- Ticket 528: Simple search bug fixed when using empty string
- Manual resources specs on qooxdoo sources

* Tue Feb 16 2010 Raul Gutierrez S. <rgs@paraguayeduca.org>
- copy database config example as default config (to be able to complete install)

* Mon Feb 15 2010 Martin Abente <mabente@paraguayeduca.org>
- Mass Re-factoring - Last details - icons bug fixed, GUI improvements

* Mon Feb 8 2010 Martin Abente <mabente@paraguayeduca.org>
- Mass Re-factoring - phase one

* Tue Jan 26 2010 Raul Gutierrez Segales <rgs@paraguayeduca.org>
- Added status column to 'where are this laptops' report

* Thu Jan 10 2010 Cesar Rodas <crodas@paraguayeduca.org>
- Spotlight it's working properly 
- Added support for "Set global scope" for current and new forms

* Thu Jan 10 2010 Cesar Rodas <crodas@paraguayeduca.org>
- Added (experimental) support for Qooxdoo 1.0
- Added (Apple's) spotlight-like support for fast access to window.

* Thu Dec 22 2009 Martin Abente <mabente@paraguayeduca.org>
- Added audit system

* Thu Dec 17 2009 Martin Abente <mabente@paraguayeduca.org>
- Fixed bug when creating change type solutions

* Thu Dec 9 2009 Martin Abente <mabente@paraguayeduca.org>
- added a new report hardware vs software distribution
- added a new report laptops problems recurrence
- addes a new report average problem solved time statistics
- removed quick solution option from abm problem reports windows

* Thu Nov 24 2009 Martin Abente <mabente@paraguayeduca.org>
- fix to spare parts registry place_id assignation
- fix string.chars.slice method for string.chars.enum_slice.to_a.first.to_s

* Mon Nov 24 2009 Raul Gutierrez Segales <rgs@paraguayeduca.org>
- migrations where missing 

* Mon Nov 23 2009 Raul Gutierrez Segales <rgs@paraguayeduca.org>
- applied initializer to prevent sweeping from calling a previously available instance of controller

* Mon Oct 5 2009 Raul Gutierrez Segales <rgs@paraguayeduca.org>
- Google's API now gets dynamically loaded (key comes from DB)
- Extension to record last activation date of laptop

* Thu Sep 24 2009 Raul Gutierrez Segales <rgs@paraguayeduca.org>
- added tch's support for notification queue
- adding tch's support for loading initial data
