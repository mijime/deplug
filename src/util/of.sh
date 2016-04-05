#!/bin/bash

__sham__util__of() {
  cd "${__v__dir}"

  local __v__tmp_file=

  for __v__tmp_file in $(eval "\\ls -1pd ${__v__of}" 2>/dev/null)
  do
    echo "source '${__v__dir}/${__v__tmp_file}';"
  done

  cd -
}
