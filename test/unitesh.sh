#!/bin/bash

__unitesh__run() {
  local \
    unittest=/tmp/unittest-$$.sh \
    stdout=/tmp/unittest-$$.out \
    stderr=/tmp/unittest-$$.err

  touch "${unittest}" "${stdout}" "${stderr}"

  cat << EOF > "${unittest}"
#!/bin/bash
export UNITTEST_NUMBER=$$;
setup() { :; }
teardown() { :; }
source "${unitfile}";

for unittest in \$(declare -f|awk '\$0~/^${prefix}.+ \\(\\)/{print\$1}')
do
  printf "%3s %3s %s" "." "?" "\$unittest";
  setup;
  printf "\\r%3s %3s %s" ".." "?" "\$unittest";
  \$unittest > "${stdout}" 2> "${stderr}";
  declare result=\$?;
  printf "\\r%3s %3s %s" "..." "\${result}" "\$unittest";
  teardown;

  if [[ \${result} -gt 0 ]]
  then
    printf "\\r%3s %3s %s\\n" "err" "\${result}" "\$unittest";
    cat "${stdout}" | sed "s/^/[\$UNITTEST_NUMBER] [OUT] /g";
    cat "${stderr}" | sed "s/^/[\$UNITTEST_NUMBER] [ERR] /g";
    break;
  elif [[ ${verbose} -gt 0 ]]
  then
    printf "\\r%3s %3s %s\\n" "ok" "\${result}" "\$unittest";
    cat "${stdout}" | sed "s/^/[\$UNITTEST_NUMBER] [OUT] /g";
    cat "${stderr}" | sed "s/^/[\$UNITTEST_NUMBER] [ERR] /g";
  else
    printf "\\r%3s %3s %s\\n" "ok" "\${result}" "\$unittest";
  fi
done
EOF

  "${shell:-bash}" "${unittest}"
  rm "${unittest}" "${stdout}" "${stderr}"
}

unitesh() {
  local \
    shell=${SHELL:-bash} \
    unitfile= \
    verbose=0 \
    parallel=0 \
    prefix=__test__

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
}

unitesh "$@"
