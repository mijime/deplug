#!/bin/bash

__sham__util__sync() {
  mkdir -p "${__g__home}" "${__g__bin}"

  local \
    __v__tmp= \
    __v__logger=/dev/null

  if [[ ! -z ${__v__verbose} ]]
  then
    __v__logger=/dev/logger
  fi

  __sham__util__disp_stat \
    | while read __v__tmp
      do
        __sham__util__parse

        case "${__v__stat}" in
          3)
            __sham__util__stringify
            continue
            ;;
        esac

        {
          local __v__scheme=${__v__from%%://*}

          if hash __sham__repo__"${__v__scheme}" >/dev/null 2>/dev/null
          then
            __sham__util__stringify 5
            __sham__repo__"${__v__scheme}" 2>&1 \
              | sed "s@^@[${__v__as}] @g" >"${__v__logger}"

            if [[ $? -gt 0 ]]
            then
              __sham__util__stringify 4
              continue
            fi

          else
            printf "%10s %s: %s\n" "[ERROR]" "No specified command" "${__v__scheme}" >&2
            __sham__util__stringify 4
            continue
          fi

          if [[ ! -z ${__v__of} ]]
          then
            __sham__util__stringify 7
            __sham__util__of >> "${__g__cache}".tmp

            if [[ $? -gt 0 ]]
            then
              __sham__util__stringify 4
              continue
            fi
          fi

          if [[ ! -z ${__v__use} ]]
          then
            __sham__util__stringify 8
            __sham__util__use 2>&1 \
              | sed "s@^@[${__v__as}] @g" >"${__v__logger}"

            if [[ $? -gt 0 ]]
            then
              __sham__util__stringify 4
              continue
            fi
          fi

          if [[ ! -z ${__v__do} ]]
          then
            __sham__util__stringify 9
            __sham__util__do 2>&1 \
              | sed "s@^@[${__v__as}] @g" >"${__v__logger}"

            if [[ $? -gt 0 ]]
            then
              __sham__util__stringify 4
              continue
            fi
          fi

          __sham__util__stringify 0
        } &
      done \
    | while read __v__tmp
      do
        __sham__util__parse

        __sham__util__disp_status >&2

        case "${__v__stat}" in
          [0-4])
            echo "${__v__tmp}"
            ;;
        esac
      done \
    > "${__g__state}".tmp
  mv "${__g__state}"{.tmp,}

  if [[ -f "${__g__cache}".tmp ]]
  then
    mv "${__g__cache}"{.tmp,}
  fi

  unset SHAM_PLUGS
}
