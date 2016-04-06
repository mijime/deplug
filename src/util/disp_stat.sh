#!/bin/bash

__sham__util__disp_stat() {
  {
    if [[ -f "${__g__state}" ]]
    then
      if [[ -z ${SHAM_PLUGS} ]]
      then
        cat "${__g__state}"
      else
        cat "${__g__state}" \
          | awk -v FS="#" -v OFS="#" -v RS="@@|\n" -v ORS="@@" \
          '$0==""{next}$10~/stat=[34]/{print;next}{print$1,$2,$3,$4,$5,$6,$7,$8,$9,"stat=3"}'
      fi
    fi

    echo "${SHAM_PLUGS[@]}"
  } \
    | awk -v FS="#" -v OFS="#" -v RS="@@|\n" -v ORS="\n" \
    'BEGIN{n=0}$3==""{next}!nl[$3]{nl[$3]=n++}{pl[$3]="#no="nl[$3]"#"$3"#"$4"#"$5"#"$6"#"$7"#"$8"#"$9"#"$10}END{for(p in pl)print pl[p]}'
}
