#!/bin/bash

__sham__cmd__status() {
  local __v__tmp=

  __sham__util__disp_stat \
    | while read __v__tmp
      do
        __sham__util__parse
        __sham__util__disp_status
      done
}
