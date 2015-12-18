benchParseArgs0() {
  seq 0 100 | while read line
  do
    __dplg__parse_arguments "test/test" dir: "${DEPLUG_HOME}/dir" --post 'cat *.sh' of:'*.sh' --use='*.sh'
  done
}

benchParseArgs1() {
  seq 0 100 | while read line
  do
    deplug "test/test" dir: "${DEPLUG_HOME}/dir" --post 'cat *.sh' of:'*.sh' --use='*.sh'
  done
}

evalute benchParseArgs0 benchParseArgs0
evalute benchParseArgs1 benchParseArgs1
