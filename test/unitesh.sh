#!/bin/bash

__unitesh__run() {
  local \
    unittest=/tmp/unittest-$$.sh \
    stdout=/tmp/unittest-$$.out \
    stderr=/tmp/unittest-$$.err

  touch "${unittest}" "${stdout}" "${stderr}"

  cat << EOF > "${unittest}"
#!/bin/bash
export UNITTEST_NO=$$;
declare maxstatus=0;

setup() { :; }
teardown() { :; }
source "${unitfile}";

for unittest in \$(declare -f|awk '\$0~/^${prefix}.+ \\(\\)/{print\$1}')
do
  printf "%3s %3s %s" "." "?" "\$unittest";
  setup > "${stdout}" 2> "${stderr}";
  printf "\\r%3s %3s %s" ".." "?" "\$unittest";
  \$unittest >> "${stdout}" 2>> "${stderr}";
  declare status=\$?;
  printf "\\r%3s %3s %s" "..." "\${status}" "\$unittest";
  teardown >> "${stdout}" 2>> "${stderr}";

  if [[ \${status} -gt 0 ]]
  then
    printf "\\r%3s %3s %s\\n" "err" "\${status}" "\$unittest";
    cat "${stdout}" | sed "s/^/[\$UNITTEST_NO] [OUT] /g";
    cat "${stderr}" | sed "s/^/[\$UNITTEST_NO] [ERR] /g";

    [[ \${maxstatus} -gt \${status} ]] || maxstatus=\${status};
    break;

  elif [[ ${verbose} -gt 0 ]]
  then
    printf "\\r%3s %3s %s\\n" "ok" "\${status}" "\$unittest";
    cat "${stdout}" | sed "s/^/[\$UNITTEST_NO] [OUT] /g";
    cat "${stderr}" | sed "s/^/[\$UNITTEST_NO] [ERR] /g";
  else
    printf "\\r%3s %3s %s\\n" "ok" "\${status}" "\$unittest";
  fi
done

exit \${maxstatus};
EOF

  time "${shell}" "${unittest}"
  status=$?
  rm "${unittest}" "${stdout}" "${stderr}"
  [[ ${maxstatus} -gt ${status} ]] || maxstatus=${status};
}

unitesh() {
  local \
    TIMEFORMAT=$'\nreal:%3lR,user:%3lU,sys:%3lS\n' \
    shell=${SHELL:-bash} \
    unitfile= \
    verbose=0 \
    parallel=0 \
    prefix=__test__ \
    status=0 \
    maxstatus=0

  while [[ $# -gt 0 ]]
  do
    case $1 in
      --shell|-s)
        shell=$2
        shift 2 || break
        ;;

      --prefix|-p)
        prefix=$2
        shift 2 || break
        ;;

      --verbose|-v)
        verbose=1
        shift || break
        ;;

      *)
        unitfile=$1

        if [[ ! -f "${unitfile}" ]]
        then shift || break
        fi

        __unitesh__run
        shift || break
        ;;
    esac
  done

  return ${maxstatus}
}

unitesh "$@"
