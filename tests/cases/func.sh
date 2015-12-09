__dplg__debug=1
__dplg__verbose=1

export DEPLUG_HOME=${cdir}/tmp
export DEPLUG_BIN=${cdir}/tmp/bin

test -d "${cdir}/tmp" && rm -r "${cdir}/tmp"
mkdir -p ${cdir}/tmp/dir "${cdir}/tmp/space dir" "${DEPLUG_BIN}"

echo "echo Include1.sh" > ${cdir}/tmp/dir/include1.sh
echo "echo Include2.sh" > ${cdir}/tmp/dir/include2.sh
echo "echo Include3.sh" > ${cdir}/tmp/dir/include3.sh
echo "echo Include4.sh" > ${cdir}/tmp/dir/include4.sh
echo "echo Include1.sh on space" > "${cdir}/tmp/space dir/include1.sh"
echo "echo Include2.sh on space" > "${cdir}/tmp/space dir/include2.sh"

find ${cdir}/tmp

evalute 'glob'  __dplg__glob  "${cdir}/tmp/dir"
evalute 'parse' __dplg__parse "name:#plugin:#dir:${cdir}/tmp/dir#tag:#post:cat *.sh#of:*.sh#use:*.sh"
evalute 'of'    __dplg__of
evalute 'use'   __dplg__use
evalute 'post'  __dplg__post

evalute 'spacedir glob'  __dplg__glob  "${cdir}/tmp/space\ dir"
evalute 'spacedir parse' __dplg__parse "name:#plugin:#dir:${cdir}/tmp/space\ dir#tag:#post:cat *.sh#of:*.sh#use:*.sh"
evalute 'spacedir of'    __dplg__of
evalute 'spacedir use'   __dplg__use
# evalute 'spacedir post'  __dplg__post # TODO

find ${cdir}/tmp
