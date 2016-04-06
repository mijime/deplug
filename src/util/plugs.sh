#!/bin/bash

__sham__util__plugs() {
  {
    if [[ -f "${__g__state}" ]]
    then
      if [[ -z ${SHAM_PLUGS} ]]
      then
        cat "${__g__state}"
      else
        cat "${__g__state}" \
          | awk -v FS="#" -v OFS="#" -v RS="@@|\n" -v ORS="@@" \
          '$0==""{next}$9~/stat=[34]/{print;next}{print$1,$2,$3,$4,$5,$6,$7,$8,"stat=3"}'
      fi
    fi

    echo "${SHAM_PLUGS[@]}"
  } \
    | awk -v FS="#" -v OFS="#" -v RS="@@|\n" -v ORS="\n" \
    'BEGIN{c=0}$2==""{next}!cl[$2]{cl[$2]=c++}{pl[$2]="#n="cl[$2]""$0}END{for(p in pl)print "#c="c,pl[p]}'
}
