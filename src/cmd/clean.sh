#!/bin/bash

__sham__cmd__clean() {
  local __v__tmp=

  __sham__plug__init

  __sham__plug__list \
    | while read __v__tmp
      do
        {
          __sham__plug__parse
          __sham__plug__stringify 14 \
            | __sham__util__logger --out /dev/stdout
          __sham__plug__clean
          __sham__plug__write_stats
          __sham__plug__stringify
        } &
      done \
    | while read __v__tmp
      do
        __sham__plug__parse
        __sham__plug__show
      done

  __sham__plug__save
  unset SHAM_PLUGS
}
