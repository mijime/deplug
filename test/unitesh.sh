#!/bin/bash

__unitesh__run() {
  local \
    __v__unittest=/tmp/unittest-$$.sh \
    __v__stdout=/tmp/unittest-$$.out \
    __v__stderr=/tmp/unittest-$$.err

  touch "${__v__unittest}" "${__v__stdout}" "${__v__stderr}"

  cat << EOF > "${__v__unittest}"
#!/bin/bash
export UNITTEST_NO=$$;
declare __v__maxstatus=0;
declare __v__status=0;

setup() { :; }
teardown() { :; }
source "${__v__unitfile}";

for __v__unittest in \$(declare -f|awk '\$0~/^${__v__prefix}.+ \\(\\)/{print\$1}')
do
  printf "%3s %3s %s" "." "?" "\${__v__unittest}";
  setup > "${__v__stdout}" 2> "${__v__stderr}";
  printf "\\r%3s %3s %s" ".." "?" "\${__v__unittest}";
  \${__v__unittest} >> "${__v__stdout}" 2>> "${__v__stderr}";
  __v__status=\$?;
  printf "\\r%3s %3s %s" "..." "\${__v__status}" "\${__v__unittest}";
  teardown >> "${__v__stdout}" 2>> "${__v__stderr}";

  if [[ \${__v__status} -gt 0 ]]
  then
    printf "\\r%3s %3s %s\\n" "err" "\${__v__status}" "\${__v__unittest}";
    cat "${__v__stdout}" | sed "s/^/[\$UNITTEST_NO] [OUT] /g";
    cat "${__v__stderr}" | sed "s/^/[\$UNITTEST_NO] [ERR] /g";

    [[ \${__v__maxstatus} -gt \${__v__status} ]] || __v__maxstatus=\${__v__status};
    break;

  elif [[ ${__v__verbose} -gt 0 ]]
  then
    printf "\\r%3s %3s %s\\n" "ok" "\${__v__status}" "\$__v__unittest";
    cat "${__v__stdout}" | sed "s/^/[\$UNITTEST_NO] [OUT] /g";
    cat "${__v__stderr}" | sed "s/^/[\$UNITTEST_NO] [ERR] /g";
  else
    printf "\\r%3s %3s %s\\n" "ok" "\${__v__status}" "\$__v__unittest";
  fi
done

exit \${__v__maxstatus};
EOF

  time "${__v__shell}" "${__v__unittest}"
  __v__status=$?
  rm "${__v__unittest}" "${__v__stdout}" "${__v__stderr}"
  [[ ${__v__maxstatus} -gt ${__v__status} ]] || __v__maxstatus=${__v__status};
}

unitesh() {
  local \
    TIMEFORMAT=$'\nreal:%3lR,user:%3lU,sys:%3lS\n' \
    __v__shell=${SHELL:-bash} \
    __v__unitfile= \
    __v__verbose=0 \
    __v__parallel=0 \
    __v__prefix=__test__ \
    __v__status=0 \
    __v__maxstatus=0

  while [[ $# -gt 0 ]]
  do
    case $1 in
      --shell|-s)
        __v__shell=$2
        shift 2 || break
        ;;

      --prefix|-p)
        __v__prefix=$2
        shift 2 || break
        ;;

      --verbose|-v)
        __v__verbose=1
        shift || break
        ;;

      *)
        __v__unitfile=$1

        if [[ ! -f "${__v__unitfile}" ]]
        then shift || break
        fi

        __unitesh__run
        shift || break
        ;;
    esac
  done

  return ${__v__maxstatus}
}

unitesh "$@"
