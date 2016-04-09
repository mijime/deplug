#!/bin/bash

__sham__plug__write_cache() {
  case ${__v__stat} in
    [0])
      ;;

    *)
      return
      ;;
  esac

  local \
    __v__tmp_file= \
    __v__dir_curr=$(pwd)

  cd "${__v__dir}"

  for __v__tmp_file in $(eval "ls --color=never -1pd ${__v__of}|grep -v '/$'" 2>/dev/null)
  do echo "source ${__v__dir}/${__v__tmp_file};"
  done >> "${__g__cache}".tmp

  cd "${__v__dir_curr}"
}
