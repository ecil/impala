#!/bin/bash
# Copyright (c) 2012 Cloudera, Inc. All rights reserved.

# This script makes a tarball of the Python-based shell that can be unzipped and
# run out-of-the-box with no configuration. The final tarball is left in
# ${IMPALA_HOME}/shell/build. 

if [ "x${IMPALA_HOME}" == "x" ]; then
  echo "\$IMPALA_HOME must be set"
  exit 1
fi

SHELL_HOME=${IMPALA_HOME}/shell
BUILD_DIR=${SHELL_HOME}/build
TARBALL_ROOT=${BUILD_DIR}/impala-shell-0.1

echo "Deleting all files in ${TARBALL_ROOT}/{gen-py,lib}"
rm -rf ${TARBALL_ROOT}/lib/* 2>&1 > /dev/null
rm -rf ${TARBALL_ROOT}/gen-py/* 2>&1 > /dev/null
mkdir -p ${TARBALL_ROOT}/lib

# Copy all the shell files into the build dir
cp -r ${HIVE_HOME}/lib/py/* ${TARBALL_ROOT}/lib
cp -r ${IMPALA_HOME}/thirdparty/python-thrift-0.7.0/thrift ${TARBALL_ROOT}/lib
cp -r ${SHELL_HOME}/gen-py ${TARBALL_ROOT}
cp ${SHELL_HOME}/impala-shell ${TARBALL_ROOT}
cp ${SHELL_HOME}/impala_shell.py ${TARBALL_ROOT}

GIT_HASH=$(git rev-parse HEAD)
BUILD_DATE=$(date)
rm -f ${TARBALL_ROOT}/lib/impala_build_version.py

cat > ${TARBALL_ROOT}/lib/impala_build_version.py <<EOF
# Copyright (c) 2012 Cloudera, Inc. All rights reserved.
# Impala version string

def get_version_string():
  return "${GIT_HASH}"

def get_build_date():
  return "${BUILD_DATE}"
EOF

pushd ${BUILD_DIR} > /dev/null
echo "Making tarball in ${BUILD_DIR}"
tar czf ${BUILD_DIR}/impala-shell-0.1.tar.gz ./impala-shell-0.1/ --exclude="*.pyc" || popd 2>&1 > /dev/null
