testInitial() {
  __dplg_v_debug=1
  __dplg_v_verbose=1
  __dplg_v_bin=${DEPLUG_HOME}/bin
  __dplg_v_cache=${DEPLUG_HOME}/cache
  __dplg_v_state=${DEPLUG_HOME}/state
  __dplg_v_repo=${DEPLUG_HOME}/repos

  test -d "${DEPLUG_HOME}" && \rm -r "${DEPLUG_HOME}"
  mkdir -p ${DEPLUG_HOME}/dir "${DEPLUG_HOME}/space dir" "${DEPLUG_BIN}"

  echo "echo Include1.sh" > ${DEPLUG_HOME}/dir/include1.sh
  echo "echo Include2.sh" > ${DEPLUG_HOME}/dir/include2.sh
  echo "echo Include3.sh" > ${DEPLUG_HOME}/dir/include3.sh
  echo "echo Include4.sh" > ${DEPLUG_HOME}/dir/include4.sh
  echo "echo Include1.sh on space" > "${DEPLUG_HOME}/space dir/include1.sh"
  echo "echo Include2.sh on space" > "${DEPLUG_HOME}/space dir/include2.sh"
}

testCase() {
  evalute 'glob'    __dplg__glob "${DEPLUG_HOME}/dir"
  evalute 'parse'   __dplg__parse_arguments "test/test" dir: "${DEPLUG_HOME}/dir" --post 'cat *.sh' of:'*.sh' --use='*.sh'
  evalute 'of'      __dplg__of
  evalute 'use'     __dplg__use
  evalute 'post'    __dplg__post
}

testCaseSpace() {
  evalute 'spacedir glob'    __dplg__glob "${DEPLUG_HOME}/space\ dir"
  evalute 'spacedir parse'   __dplg__parse_arguments "test/test" dir: "${DEPLUG_HOME}/space dir" --post 'cat *.sh' of:'*.sh' --use='*.sh'
  evalute 'spacedir of'      __dplg__of
  evalute 'spacedir use'     __dplg__use
  # evalute 'spacedir post'    __dplg__post # TODO
}

testInitial
testCase
testCaseSpace
