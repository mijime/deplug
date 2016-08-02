#!/bin/bash

__sham__cmd__install() {
  local __v__tmp=

  __sham__plug__init

  __sham__plug__list \
    | while read -r __v__tmp
      do
        {
          __sham__plug__parse
          __sham__plug__stringify 10 \
            | __sham__util__logger --out /dev/stdout
          __sham__plug__install 2>/dev/null

          if [[ ! -z ${__v__use} ]]
          then
            __sham__plug__stringify 11 \
              | __sham__util__logger --level 2 --out /dev/stdout
            __sham__plug__link 2>/dev/null
          fi

          if [[ ! -z ${__v__do} ]]
          then
            __sham__plug__stringify 12 \
              | __sham__util__logger --level 2 --out /dev/stdout
            __sham__plug__post 2>&1 \
              | __sham__util__logger --level 3 --prefix "[${__v__as}] "
          fi

          if [[ ! -z ${__v__of} ]]
          then
            __sham__plug__stringify 13 \
              | __sham__util__logger --level 2 --out /dev/stdout
            __sham__plug__write_cache
          fi

          __sham__plug__write_stats
          __sham__plug__stringify
        } &
      done \
    | while read -r __v__tmp
      do
        __sham__plug__parse
        __sham__plug__show
      done

  __sham__plug__save
  unset SHAM_PLUGS
}
