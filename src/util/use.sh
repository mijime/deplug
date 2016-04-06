#!/bin/bash

__sham__util__use() {
  local \
    __v__tmp_file= \
    __v__dir_curr=$(pwd)

  cd "${__v__dir}"

  for __v__tmp_file in $(eval "ls -1pd ${__v__use}" 2>/dev/null)
  do
    ln -sf "${__v__dir}/${__v__tmp_file}" "${__g__bin}/" >&2
  done

  cd "${__v__dir_curr}"
}
