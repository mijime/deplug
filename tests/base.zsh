#!/usr/bin/zsh -e

TEST_CASE=zsh
TEST_TARGET=${TEST_TARGET:-.*}

cdir=${0%/*}

source ${cdir}/../src/base.sh
source ${cdir}/../src/zsh/*.zsh
source ${cdir}/utils/*.sh
ls -1p ${cdir}/cases/*.sh | grep "${TEST_TARGET}" | while read testcase
do source ${testcase}
done
