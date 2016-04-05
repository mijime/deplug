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
  printf "%4s %s" "." "\$unittest";
  setup;
  printf "\\r%4s %s" ".." "\$unittest";
  \$unittest > "${stdout}" 2> "${stderr}";
  declare result=\$?;
  printf "\\r%4s %s" "..." "\$unittest";
  teardown;
  printf "\\r%4s %s\\n" "\${result}" "\$unittest";

  if [[ \${result} -gt 0 ]] || [[ ${verbose} -eq 1 ]]
  then 
    cat "${stdout}" | sed "s/^/[\$UNITTEST_NUMBER] [OUT] /g";
    cat "${stderr}" | sed "s/^/[\$UNITTEST_NUMBER] [ERR] /g";
  fi
done
EOF

  "${SHELL:-bash}" "${unittest}"
  rm "${unittest}" "${stdout}" "${stderr}"
}

unitesh() {
  local \
    unitfile= \
    verbose=0 \
    parallel=0 \
    prefix=__test__

  while [[ $# -gt 0 ]]
  do
    case $1 in
      --verbose|-v)
        verbose=1
        shift || break
        ;;

      --parallel|-p)
        parallel=1
        shift || break
        ;;

      *)
        unitfile=$1

        if [[ ! -f "${unitfile}" ]]
        then shift || break
        fi

        if [[ ${parallel} -eq 0 ]]
        then __unitesh__run
        else __unitesh__run &
        fi

        shift || break
        ;;
    esac
  done
}

unitesh "$@"
