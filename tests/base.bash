#!/usr/bin/bash -e

TEST_CASE=bash
TEST_TARGET=${TEST_TARGET:-.*}
SHELL=/usr/bin/bash

cdir=${0%/*}

export DEPLUG_HOME=${cdir}/tmp/bash
export DEPLUG_BIN=${cdir}/tmp/bash/bin
export DEPLUG_SRC=${cdir}/tmp/bash/source
export DEPLUG_STAT=${cdir}/tmp/bash/state
export DEPLUG_REPO=${cdir}/tmp/bash/repos

source ${cdir}/../src/common.sh
source ${cdir}/../src/bash/*.bash
source ${cdir}/utils/*.sh
ls -1p ${cdir}/cases/*.sh | grep "${TEST_TARGET}" | while read testcase
do source ${testcase}
done
