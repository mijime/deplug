benchParseArgs0() {
  seq 0 100 | while read line
  do
    __sham__parse_arguments "test/test" dir: "${SHAM_HOME}/dir" --post 'cat *.sh' of:'*.sh' --use='*.sh'
  done
}

benchParseArgs1() {
  seq 0 100 | while read line
  do
    sham "test/test" dir: "${SHAM_HOME}/dir" --post 'cat *.sh' of:'*.sh' --use='*.sh'
  done
}

evalute benchParseArgs0 benchParseArgs0
evalute benchParseArgs1 benchParseArgs1
