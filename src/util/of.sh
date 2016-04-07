#!/bin/bash

__sham__util__of() {
  local \
    __v__tmp_file= \
    __v__dir_curr=$(pwd)

  cd "${__v__dir}"

  for __v__tmp_file in $(eval "ls --color=never -1pd ${__v__of}" 2>/dev/null)
  do
    echo "source '${__v__dir}/${__v__tmp_file}';"
  done

  cd "${__v__dir_curr}"
}
