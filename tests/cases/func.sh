__dplg__debug=1
__dplg__verbose=1

test -d "${DEPLUG_HOME}" && \rm -r "${DEPLUG_HOME}"
mkdir -p ${DEPLUG_HOME}/dir "${DEPLUG_HOME}/space dir" "${DEPLUG_BIN}"

echo "echo Include1.sh" > ${DEPLUG_HOME}/dir/include1.sh
echo "echo Include2.sh" > ${DEPLUG_HOME}/dir/include2.sh
echo "echo Include3.sh" > ${DEPLUG_HOME}/dir/include3.sh
echo "echo Include4.sh" > ${DEPLUG_HOME}/dir/include4.sh
echo "echo Include1.sh on space" > "${DEPLUG_HOME}/space dir/include1.sh"
echo "echo Include2.sh on space" > "${DEPLUG_HOME}/space dir/include2.sh"

find ${DEPLUG_HOME}

evalute 'glob'  __dplg__glob  "${DEPLUG_HOME}/dir"
evalute 'parse' __dplg__parse "name:#plugin:#dir:${DEPLUG_HOME}/dir#tag:#post:cat *.sh#of:*.sh#use:*.sh"
evalute 'of'    __dplg__of
evalute 'use'   __dplg__use
evalute 'post'  __dplg__post
evalute 'load'  __dplg__load

evalute 'spacedir glob'  __dplg__glob  "${DEPLUG_HOME}/space\ dir"
evalute 'spacedir parse' __dplg__parse "name:#plugin:#dir:${DEPLUG_HOME}/space\ dir#tag:#post:cat *.sh#of:*.sh#use:*.sh"
evalute 'spacedir of'    __dplg__of
evalute 'spacedir use'   __dplg__use
evalute 'spacedir load'  __dplg__load
# evalute 'spacedir post'  __dplg__post # TODO

find ${DEPLUG_HOME}
