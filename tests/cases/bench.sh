benchParseArgs() {
  seq 0 100 | while read line
  do
    time __dplg_f_parseArgs "test/test" dir: "${DEPLUG_HOME}/dir" --post 'cat *.sh' of:'*.sh' --use='*.sh'
  done
}
evalute benchParseArgs benchParseArgs
