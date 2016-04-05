#!/bin/bash

__sham__cmd__status() {
  local __v__tmp=

  __sham__util__plugs \
    | while read __v__tmp
      do
        __sham__util__parse

        case ${__v__stat} in
          0)
            echo "Installed ${__v__as}"
            ;;
          1)
            echo "NoInstall ${__v__as}"
            ;;
          2)
            echo "Update    ${__v__as}"
            ;;
          3)
            echo "Cached    ${__v__as}"
            ;;
          4)
            echo "Failed    ${__v__as}"
            ;;
        esac
      done
}
