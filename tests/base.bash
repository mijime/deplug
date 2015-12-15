#!/usr/bin/bash -e

TEST_CASE=bash
TEST_TARGET=${TEST_TARGET:-.*}
SHELL=/usr/bin/bash

cdir=${0%/*}

export DEPLUG_HOME=/tmp/tests/bash
export DEPLUG_BIN=/tmp/tests/bash/bin
export DEPLUG_CACHE=/tmp/tests/bash/cache
export DEPLUG_STATE=/tmp/tests/bash/state
export DEPLUG_REPO=/tmp/tests/bash/repos

source ${cdir}/../src/command.sh
source ${cdir}/../src/function.sh
source ${cdir}/../src/bash/*.bash
source ${cdir}/utils/*.sh
ls -1p ${cdir}/cases/*.sh | grep "${TEST_TARGET}" | while read testcase
do source ${testcase}
done
