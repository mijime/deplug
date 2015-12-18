#!/usr/bin/bash -e

TEST_TARGET=${TEST_TARGET:-.*}
cdir=$(cd $(dirname $0);pwd)

include_files() {
  cat <<EOF
  TEST_CASE=bash
  SHELL=/usr/bin/bash

  export DEPLUG_HOME=/tmp/tests/bash
  export DEPLUG_BIN=/tmp/tests/bash/bin
  export DEPLUG_CACHE=/tmp/tests/bash/cache
  export DEPLUG_STATE=/tmp/tests/bash/state
  export DEPLUG_REPO=/tmp/tests/bash/repos
EOF
  cat ${cdir}/../src/*.sh ${cdir}/../src/*.bash
  cat ${cdir}/utils/*.sh
  ls -1p ${cdir}/cases/*.sh | grep "${TEST_TARGET}" | xargs cat
}

include_files | bash ${TEST_OPTIONS}
