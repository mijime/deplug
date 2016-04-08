#!/bin/bash

__sham__plug__link() {
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

  for __v__tmp_file in $(eval "ls --color=never -1pd ${__v__use}|grep -v '/$'" 2>/dev/null)
  do
    ln -sf "${__v__dir}/${__v__tmp_file}" "${__g__bin}/"
  done

  cd "${__v__dir_curr}"
}
