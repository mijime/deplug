#!/bin/bash

__sham__cmd__status() {
  local __v__tmp=

  __sham__plug__list \
    | while read __v__tmp
      do
        __sham__plug__parse
        __sham__plug__show
      done
}
