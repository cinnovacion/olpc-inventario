# spec file for our tracking, monitoring and support web app
Name: inventario		
Version: 0.4
Release: 15
Vendor: Paraguay Educa
Summary: This (Ruby on Rails based) web app lets you track laptops given out, status of networks and support tickets.
Group:	Applications/Internet
License: GPL	
URL: http://git.paraguayeduca.org/gitweb/projects/inventario.git
Source0: %{name}-%{version}.tar.gz
Requires: ruby(abi) = 1.8, crontabs, rubygems, rubygem-activesupport, rubygem-activeresource, rubygem-rails, mysql-server, htmldoc, httpd, ruby-mysql, ruby-json, rubygem-gruff, rubygem-spreadsheet-excel, rubygem-parseexcel, rubygem-gbarcode, logrotate, rubygem-fast_gettext, rubygem-mysql2, rubygem-will_paginate

# acts_as_audited gemspec needs this
Requires: git

BuildArch: noarch

%description
This web application is meant to be use by deployments who need to track what laptop has been given to who (inventory), maintain a real-time status of the deployed wi-fi networks (monitoring) and register tickets of tech problems found (support). 

In order to use certain features (i.e.: monitoring) additional packages should be installed in schoolservers. 

%prep
%setup -q

%build
%install
mkdir -p $RPM_BUILD_ROOT/var/%{name}
mkdir -p $RPM_BUILD_ROOT/etc/cron.d
cp extra/cron.d/* $RPM_BUILD_ROOT/etc/cron.d
mkdir -p $RPM_BUILD_ROOT/etc/logrotate.d
cp extra/inventario-logrotate $RPM_BUILD_ROOT/etc/logrotate.d/inventario
cp -r * $RPM_BUILD_ROOT/var/%{name}
test -d $RPM_BUILD_ROOT/var/%{name}/public/build && rm -rf $RPM_BUILD_ROOT/var/%{name}/public/build > /dev/null 2>&1
# Qooxdoo no maneja links simbolicos :(
ln -s /usr/share/qooxdoo-sdk $RPM_BUILD_ROOT/var/%{name}/public
cd $RPM_BUILD_ROOT/var/%{name}
rake gui:generate[build]

# kill sym link de qooxdoo-sdk
rm $RPM_BUILD_ROOT/var/%{name}/public/qooxdoo-sdk

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
/var/%{name}/config.ru
/var/%{name}/COPYING
/var/%{name}/README
/var/%{name}/db
/var/%{name}/doc
/var/%{name}/lib
%attr(-,apache,apache) /var/%{name}/log
/var/%{name}/public
%attr(-,apache,apache) /var/%{name}/public/images
%attr(-,apache,apache) /var/%{name}/public/system
%attr(-,apache,apache) /var/%{name}/public/system/barcodes
/var/%{name}/Rakefile
/var/%{name}/INSTALL
/var/%{name}/script
/var/%{name}/test
%attr(-,apache,apache) /var/%{name}/tmp
/var/%{name}/translation
/var/%{name}/vendor

%changelog
* Fri Aug 26 2011 Martin Abente. <tch@paraguayeduca.org>
- Enforce people import policy
- Update translations

* Thu Aug 18 2011 Martin Abente. <tch@paraguayeduca.org>
- Fix latin encoding

* Wed Aug 17 2011 Martin Abente. <tch@paraguayeduca.org>
- Fix movement and audit reports

* Tue Aug 16 2011 Martin Abente. <tch@paraguayeduca.org>
- Laptop data integrity check report
- Fix HierarchyOnDemand selection
- Remove useless code
- List document_id on .xls
- Robust laptops_uuid report

* Tue Aug 9 2011 Martin Abente. <tch@paraguayeduca.org>
- Robust Place.getSerialsInfo

* Fri Aug 5 2011 Martin Abente. <tch@paraguayeduca.org>
- Update qooxdoo version
- Better handling of places without place type
- Improve robustness to childrens xls import process
- Improve Place.getSerialsInfo performance
- XS config can use any location type
- New report list childrens ID documents

* Tue Sep 21 2010 Martin Abente. <mabente@paraguayeduca.org>
- Fix repeated problem reports script
- Fix node tracker node type filter
- Add lot information report

* Mon Sep 20 2010 Martin Abente. <mabente@paraguayeduca.org>
- Removed deletion of repeated problem reports script

* Fri Sep 17 2010 Martin Abente. <mabente@paraguayeduca.org>
- Laptops and uuids report extension

* Mon Sep 13 2010 Martin Abente. <mabente@paraguayeduca.org>
- Fix teachers import script

* Fri Sep 10 2010 Martin Abente. <mabente@paraguayeduca.org>
- Bug fixes
- Problems time response new laptops models filter

* Fri Sep 10 2010 Daniel Drake. <dsd@laptop.org>
- Mass people move
- Script runner enhancements
- Bug fixes

* Tue Aug 17 2010 Daniel Drake. <dsd@laptop.org>
- Assigments system
- Interface enhancements
- Bug fixes

* Fri Jul 09 2010 Martin Abente. <mabente@paraguayeduca.org>
- Mass delivery null fields bug fix

* Thu Jul 08 2010 Martin Abente. <mabente@paraguayeduca.org>
- Barcodes for everyone and extensions for barcode printing report

* Fri Jun 25 2010 Martin Abente. <mabente@paraguayeduca.org>
- Daniel Drake enhancements, bug fixes and Assignment model for Peru

* Mon May 31 2010 Martin Abente. <mabente@paraguayeduca.org>
- Added solved filter to hardware vs software problems distro report

* Mon Apr 26 2010 Martin Abente. <mabente@paraguayeduca.org>
- Added monthly frenquency and average frequency to problems per window time distribution report

* Mon Mar 22 2010 Martin Abente. <mabente@paraguayeduca.org>
- Fixes to demo data script

* Fri Mar 18 2010 Raul Gutierrez S. <rgs@paraguayeduca.org>
- Improvements for the es translations on the gui side

* Fri Mar 18 2010 Martin Abente. <mabente@paraguayeduca.org>
- English translations fixes by Paulah Saphir

* Fri Mar 05 2010 Martin Abente. <mabente@paraguayeduca.org>
- Tool Box bug fixes and missing translations

* Fri Mar 05 2010 Raul Gutierrez S. <rgs@paraguayeduca.org>
- Qooxdoo 1.x doesnt handle repeated values in SelectBox. Added a hack around this. 

* Thu Mar 04 2010 Raul Gutierrez S. <rgs@paraguayeduca.org>
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
