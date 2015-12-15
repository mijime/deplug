#!/usr/bin/zsh -e

TEST_CASE=zsh
TEST_TARGET=${TEST_TARGET:-.*}
SHELL=/usr/bin/zsh

cdir=${0%/*}

export DEPLUG_HOME=/tmp/tests/zsh
export DEPLUG_BIN=/tmp/tests/zsh/bin
export DEPLUG_CACHE=/tmp/tests/zsh/cache
export DEPLUG_STATE=/tmp/tests/zsh/state
export DEPLUG_REPO=/tmp/tests/zsh/repos

source ${cdir}/../src/command.sh
source ${cdir}/../src/function.sh
source ${cdir}/../src/zsh/*.zsh
source ${cdir}/utils/*.sh
ls -1p ${cdir}/cases/*.sh | grep "${TEST_TARGET}" | while read testcase
do source ${testcase}
done
