#!/usr/bin/bash -e

TEST_CASE=bash
TEST_TARGET=${TEST_TARGET:-.*}

cdir=${0%/*}

source ${cdir}/../src/base.sh
source ${cdir}/../src/bash/*.bash
source ${cdir}/utils/*.sh
ls -1p ${cdir}/cases/*.sh | grep "${TEST_TARGET}" | while read testcase
do source ${testcase}
done
