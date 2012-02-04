# http://noopsi.com/item/14345/find_linux_version_linux_learned/
alias version='cat /etc/lsb-release'
alias v='version'

# http://noopsi.com/item/12779/check_disk_space_linux_learned_linux_cmdline/
alias disk='du -h . |sort -n -r; df -h'

# count all the files in a directory
alias fcount='ls -l | wc -l'

# http://stackoverflow.com/questions/941338/shell-script-how-to-pass-command-line-arguments-to-an-unix-alias
# quickly check what processes are running
function r(){
	ps aux | grep $1
}
function running(){
  r $1
}

# get the running time of the process that match user passed in value
function rtime(){
	ps -eo pid,etime,cmd:180 | grep $1
}

# find all the folders of passed in value
function where(){
	echo 'sudo find / -type d -name $1'
	sudo find / -type d -iname $1
	#sudo find / -type d | grep $1
}
# find all folders, but use grep instead, nice because it prints sub-folders
function whereg(){
	echo 'sudo find / -type d | grep $1'
	sudo find / -type d | grep $1
}

# http://stackoverflow.com/a/68600/5006
function bak(){
  cp $1{,-bak}
}

# returns the return code of the last run command
function ret(){
  echo $?
}

function hist(){
  history | grep $1
}

# print alias help
function help(){
  echo 'ret               returns the result code of the last run command'
  # http://stackoverflow.com/a/68397/5006
  echo 'cd -              go to the previous directory (similar to pop)'
  # http://stackoverflow.com/a/68429/5006
  echo 'sudo !!           run the last command, but with sudo'
  # http://stackoverflow.com/a/171938/5006
  echo 'ls -d */          list only subdirectories of the current dir'
  echo 'hist [NAME]       list history items matching NAME'
  echo 'running [NAME]    return what processes matching NAME are currently running'
  echo 'rtime [NAME]      get running time of processes matching name'
  echo 'version           return linux version information'
  echo 'disk              what is using the most disk space'
  echo 'fcount            count how many files in the current directory'
  echo 'where [NAME]      find all folders with NAME'
  # http://noopsi.com/item/11479/quick_reference_keyboard_shortcuts_cli_linux_learned/
  # http://stackoverflow.com/questions/68372/what-is-your-single-most-favorite-command-line-trick-using-bash
  echo 'Bash shell keyboard shortcuts:'
  echo '  bind -p show all keyboard shorcuts'
  echo '  Ctrl^a 	Move the cursor to the beginning of the input line.'
  echo '  Ctrl^d 	Same as [DEL] (this is the Emacs equivalent).'
  echo '  Ctrl^e 	Move the cursor to the end of the input line.'
  echo '  Ctrl^k 	Kill, or "cut," all text on the input line, from the character' 
  echo '          the cursor is underneath to the end of the line.'
  echo '  Ctrl^l 	Clear the terminal screen.'
  echo '  Ctrl^u 	Kill the entire input line.'
  echo '  Ctrl^y 	Yank, or "paste," the text that was last killed. Text is' 
  echo '          inserted at the point where the cursor is.'
  echo '  Ctrl^_ 	Undo the last thing typed on this command line'
}

# http://old.nabble.com/show-all-if-ambiguous-broken--td1613156.html
# http://stackoverflow.com/a/68449/5006
# http://liquidat.wordpress.com/2008/08/20/short-tip-bash-tab-completion-with-one-tab/
# http://superuser.com/questions/271626/
bind "set completion-ignore-case on"
bind "set show-all-if-ambiguous on"
bind "set mark-symlinked-directories on"
bind "set show-all-if-unmodified on"

# http://stackoverflow.com/a/69087/5006
# do ". acd_func.sh"
# acd_func 1.0.5, 10-nov-2004
# petar marinov, http:/geocities.com/h2428, this is public domain
cd_func ()
{
  local x2 the_new_dir adir index
  local -i cnt

  if [[ $1 ==  "--" ]]; then
    dirs -v
    return 0
  fi

  the_new_dir=$1
  [[ -z $1 ]] && the_new_dir=$HOME

  if [[ ${the_new_dir:0:1} == '-' ]]; then
    #
    # Extract dir N from dirs
    index=${the_new_dir:1}
    [[ -z $index ]] && index=1
    adir=$(dirs +$index)
    [[ -z $adir ]] && return 1
    the_new_dir=$adir
  fi

  #
  # '~' has to be substituted by ${HOME}
  [[ ${the_new_dir:0:1} == '~' ]] && the_new_dir="${HOME}${the_new_dir:1}"

  #
  # Now change to the new dir and add to the top of the stack
  pushd "${the_new_dir}" > /dev/null
  [[ $? -ne 0 ]] && return 1
  the_new_dir=$(pwd)

  #
  # Trim down everything beyond 11th entry
  popd -n +11 2>/dev/null 1>/dev/null

  #
  # Remove any other occurence of this dir, skipping the top of the stack
  for ((cnt=1; cnt <= 10; cnt++)); do
    x2=$(dirs +${cnt} 2>/dev/null)
    [[ $? -ne 0 ]] && return 0
    [[ ${x2:0:1} == '~' ]] && x2="${HOME}${x2:1}"
    if [[ "${x2}" == "${the_new_dir}" ]]; then
      popd -n +$cnt 2>/dev/null 1>/dev/null
      cnt=cnt-1
    fi
  done

  return 0
}

alias cd=cd_func

if [[ $BASH_VERSION > "2.05a" ]]; then
  # ctrl+w shows the menu
  bind -x "\"\C-w\":cd_func -- ;"
fi

