testInitial() {
  __dplg_v_debug=1
  __dplg_v_verbose=1
  __dplg_v_bin=${SHAM_HOME}/bin
  __dplg_v_cache=${SHAM_HOME}/cache
  __dplg_v_state=${SHAM_HOME}/state
  __dplg_v_repo=${SHAM_HOME}/repos

  test -d "${SHAM_HOME}" && rm -r "${SHAM_HOME}"
  mkdir -p ${SHAM_HOME}/dir "${SHAM_HOME}/space dir" "${SHAM_BIN}"

  echo "echo Include1.sh" > ${SHAM_HOME}/dir/include1.sh
  echo "echo Include2.sh" > ${SHAM_HOME}/dir/include2.sh
  echo "echo Include3.sh" > ${SHAM_HOME}/dir/include3.sh
  echo "echo Include4.sh" > ${SHAM_HOME}/dir/include4.sh
  echo "echo Include1.sh on space" > "${SHAM_HOME}/space dir/include1.sh"
  echo "echo Include2.sh on space" > "${SHAM_HOME}/space dir/include2.sh"
}

testCase() {
  evalute 'glob'    __sham__glob "${SHAM_HOME}/dir"
  evalute 'parse'   __sham__parse_arguments "test/test" dir: "${SHAM_HOME}/dir" --post 'cat *.sh' of:'*.sh' --use='*.sh'
  evalute 'of'      __sham__of
  evalute 'use'     __sham__use
  evalute 'post'    __sham__post
}

testCaseSpace() {
  evalute 'spacedir glob'    __sham__glob "${SHAM_HOME}/space\ dir"
  evalute 'spacedir parse'   __sham__parse_arguments "test/test" dir: "${SHAM_HOME}/space dir" --post 'cat *.sh' of:'*.sh' --use='*.sh'
  evalute 'spacedir of'      __sham__of
  evalute 'spacedir use'     __sham__use
  # evalute 'spacedir post'    __sham__post # TODO
}

testInitial
testCase
testCaseSpace
