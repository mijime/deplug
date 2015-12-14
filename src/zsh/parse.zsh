__dplg_f_parse() {
  local __dplg_v_args=()

  __dplg_v_args=("${(s/#/)@}")

  __dplg_v_as=${__dplg_v_args[1]#as:}
  __dplg_v_plugin=${__dplg_v_args[2]#plugin:}
  __dplg_v_dir=${__dplg_v_args[3]#dir:}
  __dplg_v_tag=${__dplg_v_args[4]#tag:}
  __dplg_v_of=${__dplg_v_args[5]#of:}
  __dplg_v_use=${__dplg_v_args[6]#use:}
  __dplg_v_post=${__dplg_v_args[7]#post:}
  __dplg_v_from=${__dplg_v_args[8]#from:}
}


__dplg_f_color(){
  autoload -Uz colors &&colors
  __dplg_v_colo[bla]="${fg[black]}"
  __dplg_v_colo[red]="${fg[red]}"
  __dplg_v_colo[gre]="${fg[green]}"
  __dplg_v_colo[yel]="${fg[yellow]}"
  __dplg_v_colo[blu]="${fg[blue]}"
  __dplg_v_colo[mag]="${fg[magenda]}"
  __dplg_v_colo[cya]="${fg[cyan]}"
  __dplg_v_colo[whi]="${fg[white]}"
  __dplg_v_colo[res]="${reset_color}"
}
