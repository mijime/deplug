#!/bin/bash

__sham__util__disp_stat() {
  if [[ -z ${SHAM_PLUGS} ]] && [[ -f "${__g__state}" ]]
  then
    cat "${__g__state}"
    return
  fi

  {
    if [[ -f "${__g__state}" ]]
    then
      cat "${__g__state}" \
        | awk -v FS="#" -v OFS="#" -v RS="@@|\n" -v ORS="@@" \
        '$0==""{next}{print"cache"$0}'
    fi

    echo "${SHAM_PLUGS[@]}"
  } \
    | awk -v FS="#" -v OFS="#" -v RS="@@|\n" -v ORS="\n" \
    'BEGIN{n=0}$3==""{next}
    !nl[$3]{nl[$3]=n++}
    {ctx=$3"#"$4"#"$5"#"$6"#"$7"#"$8"#"$9}
    $1=="cache"&&$10~/stat=[^4]/{st[$3]="stat=3"}
    $1=="cache"&&$10~/stat=[4]/{st[$3]="stat=4"}
    $1!="cache"&&$10~/stat=[^2]/{st[$3]=$10}
    $1!="cache"&&$10~/stat=[2]/{if(pl[$3]==ctx){st[$3]="stat=0"}else{st[$3]="stat=2"}}
    {pl[$3]=ctx}
    END{for(p in pl)print"#no="nl[p],pl[p],st[p]}'
}
