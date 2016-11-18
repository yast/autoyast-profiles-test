#
# spec file for package yast2-services-manager
#
# Copyright (c) 2015 SUSE LINUX Products GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#


######################################################################
#
# IMPORTANT: Please do not change spec file in build service directly
#            Use https://github.com/yast/autoyast-profiles-test
#
######################################################################

Name:           autoyast-profiles-test
Version:        0.0.2
Release:        0
BuildArch:      noarch

BuildRoot:      %{_tmppath}/%{name}-build
Source0:        %{name}-%{version}.tar.bz2

BuildRequires:  rubygem(rspec)
BuildRequires:  rubygem(yast-rake)
BuildRequires:  rubygem(cheetah)
BuildRequires:  yast2-schema
BuildRequires:  jing

Requires:       rubygem(rspec)
Requires:       rubygem(yast-rake)
Requires:       rubygem(cheetah)
Requires:       yast2-schema
Requires:       jing

Summary:        YaST2 - Automated test for AutoYast
Group:          System/YaST
License:        GPL-2.0 or GPL-3.0
Url:            https://github.com/yast/autoyast-profiles-test

%description
Provides automated test for AutoYast schema and profiles

%prep
%setup -n %{name}-%{version}

%check
rake test:unit

%install

%files
%defattr(-,root,root)
