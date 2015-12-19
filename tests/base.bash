#!/usr/bin/bash -e

TEST_TARGET=${TEST_TARGET:-.*}
cdir=$(cd $(dirname $0);pwd)

include_files() {
  cat <<EOF
  TEST_CASE=bash
  SHELL=/usr/bin/bash

  export SHAM_HOME=/tmp/tests/bash
  export SHAM_BIN=/tmp/tests/bash/bin
  export SHAM_CACHE=/tmp/tests/bash/cache
  export SHAM_STATE=/tmp/tests/bash/state
  export SHAM_REPO=/tmp/tests/bash/repos
EOF
  cat ${cdir}/../src/*.sh ${cdir}/../src/*.bash
  cat ${cdir}/utils/*.sh
  ls -1p ${cdir}/cases/*.sh | grep "${TEST_TARGET}" | xargs cat
}

include_files | bash ${TEST_OPTIONS}
