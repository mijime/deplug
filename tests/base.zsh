#!/usr/bin/zsh -e

TEST_CASE=zsh
TEST_TARGET=${TEST_TARGET:-.*}
SHELL=/usr/bin/zsh

cdir=${0%/*}

export DEPLUG_HOME=${cdir}/tmp/zsh
export DEPLUG_BIN=${cdir}/tmp/zsh/bin
export DEPLUG_SRC=${cdir}/tmp/zsh/source

source ${cdir}/../src/common.sh
source ${cdir}/../src/zsh/*.zsh
source ${cdir}/utils/*.sh
ls -1p ${cdir}/cases/*.sh | grep "${TEST_TARGET}" | while read testcase
do source ${testcase}
done
