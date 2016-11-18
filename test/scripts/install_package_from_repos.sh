#!/bin/bash

#
# This script downloads and installs a package to temporary directory from
# given list of zypp repositories. It uses zypp to decide which package is
# the newest and then it's downloaded 
#

ROOT_DIR=$1; shift
ARCH=$1; shift
PACKAGE=$1; shift
ZYPP_REPOS=$@

ZYPPER_GLOBAL_PARAMS="--non-interactive --verbose --root ${ROOT_DIR}"

# Usage
if [ "${ROOT_DIR}" == "" ] || [ "${PACKAGE}" == "" ] || [ "${ZYPP_REPOS}" == "" ]; then
    echo "Installs given package into given directory from list of zypp repositories."
    echo
    echo "Usage: $0 directory package zypp_repo [another_zypp_repo [another_zypp_repo...]]"
    exit 1
fi

echo "Installing package ${PACKAGE} to ${ROOT_DIR} from repositories: ${ZYPP_REPOS}"

# Make sure that the temporary directory exists and it's empty
if [ ! -e "${ROOT_DIR}" ]; then
    mkdir -pv ${ROOT_DIR}
elif [ "`ls ${ROOT_DIR}`" != "" ]; then
    echo "${ROOT_DIR} is not empty"
    exit 1
fi

# Add zypp repositories
REPO_COUNTER=0
for REPO_URL in ${ZYPP_REPOS}; do
    REPO_COUNTER=$((REPO_COUNTER+1))
    zypper ${ZYPPER_GLOBAL_PARAMS} addrepo --no-gpgcheck --refresh ${REPO_URL} temporary_${REPO_COUNTER} || exit 1
done

export ZYPP_TESTSUITE_FAKE_ARCH=${ARCH}
# Download the requested package
zypper ${ZYPPER_GLOBAL_PARAMS} --disable-system-resolvables download ${PACKAGE} || exit 1

# Find where the package is downloaded and install it (without any dependencies)
for PACKAGE_LOCATION in `find ${ROOT_DIR} -name ${PACKAGE}*.rpm`; do
    echo "Installing ${PACKAGE_LOCATION} to ${ROOT_DIR}"
    rpm -v --root ${ROOT_DIR} --install --nodeps --noscripts --notriggers --nosignature --ignorearch ${PACKAGE_LOCATION} || exit 1
done

if [ "${PACKAGE_LOCATION}" == "" ]; then
    echo "Cannot find package ${PACKAGE} in ${ROOT_DIR}"
    exit 1
fi

exit 0
