
# colors
# use them in echo like this: echo -e "${RED}test${NONE}"
YELLOW='\e[0;33m'
PURPLE='\e[0;35m'
CYAN='\e[0;36m'
WHITE='\e[0;37m'
RED='\e[0;31m'
GREEN='\e[0;32m'
BLACK='\e[0;30m'
BLUE='\e[0;34m'
NONE='\e[0m' # Text Reset

# http://noopsi.com/item/14345/find_linux_version_linux_learned/
#? version -> return linux version information
alias version='cat /etc/lsb-release'
alias v='version'

# have less, by default, give more information on the prompt
# 2-20-12 
# http://en.wikipedia.org/wiki/Less_%28Unix%29
alias less='less -M'

# this is here because I can never remember how to untar and unzip a freaking .tar.gz file
#? untar FILE -> untar and unzip FILE (a .tar.gz file)
# 2-20-12
function untar(){
  echo tar -xzf $1
  tar -xzf $1
}

#? mkcd DIR -> create DIR then change into it
# since 3-10-12
function mkcd(){
  mkdir -p $1
  cd $1
}

# http://noopsi.com/item/12779/check_disk_space_linux_learned_linux_cmdline/
#? disk -> what is using the most disk space
#? disk [PATH] [COUNT] -> return biggest [COUNT] file sizes in [PATH] 
function disk(){

  # defaults
  pth=/
  cnt=25
  
  # if there is only one argument it could be a path or a count
  # count or path can be interchangeable
  if [ $# -ge 1 ]; then
  
    if [ -d $1 ]; then
    
      pth=$1
      
      if [ "$2" > "0" ]; then
      
        cnt=$2
      
      fi

    
    else
    
      if [ "$1" > "0" ]; then
    
        cnt=$1
        
      fi
      
      if [ -d $2 ]; then
      
        pth=$2
      
      fi
    
    fi
  
  fi
  
  echo -e "${BLUE}= = = = = = Largest $cnt things in $pth${NONE}"
  sudo du -h $pth | sort -n -r | head -n $cnt
  
  echo -e "${RED}= = = = = = Total disk usage${NONE}"
  df -h

}

# count all the files in a directory
#? fcount -> count how many files in the current directory
alias fcount='ls -l | wc -l'

# print out the computer's current ip address
# http://www.coderholic.com/invaluable-command-line-tools-for-web-developers/
#? myip -> print out current external ip address
alias myip='curl ifconfig.me'

# http://stackoverflow.com/questions/941338/shell-script-how-to-pass-command-line-arguments-to-an-unix-alias
# quickly check what processes are running
#? running <NAME> -> return what processes matching NAME are currently running
function running(){
  # filter out the grep process
	ps aux | grep -v "grep" | grep $1
}
alias r=running

# get the running time of the process that match user passed in value
#? rtime <NAME> -> get running time of processes matching name'
function rtime(){
	ps -eo pid,etime,cmd | grep -v "grep" | grep $1
}

#? murder <NAME> -> run every process that matches NAME through sudo kill -9
# 2-20-12
# http://stackoverflow.com/questions/262597/how-to-kill-a-linux-process-by-stime-dangling-svnserve-processes
function murder(){
  echo -e "${RED}These will be killed:${NONE}"
  ps -eo pid,cmd | grep -v "grep" | grep $1
  # first 3 commands find the right running processes
  # sed - gets rid of any whitespace from the front of the command
  # cut - gets the first column (in this case, the pid)
  # xargs - runs each found pid through the kill command
  ps -eo pid,cmd | grep -v "grep" | grep "$1" | sed "s/^ *//" | cut -d' ' -f1 | xargs -i sudo kill -9 "{}"
}

# find all the folders of passed in value
#? where <NAME> -> find all folders with NAME (supports * wildcard)
function where(){
  echo " = = = = Directories"
	echo "sudo find / -type d -iname $1"
	sudo find / -type d -iname $1
	echo " = = = = Files"
	echo "sudo find / -type f -iname $1"
  sudo find / -type f -iname $1
  #sudo find / -type d | grep $1
}

# http://stackoverflow.com/a/68600/5006
#? bak <filepath> -> make a copy of filepath named filepath.bak
function bak(){
  cp $1{,.bak}
}
#? mbak <filepath> -> rename a file from filepath to filepath.bak
function mbak(){
  mv $1{,.bak}
}

#? ret -> returns the result code of the last run command
# http://stackoverflow.com/a/68397/500
alias ret='echo $?'

#? hist,h <cmd> -> get all the commands in history matching cmd
function hist(){
  history | grep $1
}
alias h=hist

#? histl,hl <N> -> display the last N commands
# since 3-10-12
function histl(){
  
  cnt=25
  if [ "$#" -gt 0 ]; then
    
    cnt=$1
    
  fi

  history | tail -n $cnt
}
alias hl=histl

# added 2-18-12
#? idr,initd <NAME> -> init.d restart <NAME>
function idr(){
  echo "/etc/init.d/$1 restart"
  sudo /etc/init.d/$1 restart
}
alias initr=idr
alias initd=idr
alias itd=idr
alias itr=idr

#? .. -> cd ..
alias ..='cd ..' 
#? ... -> cd ../..
alias ...='cd ../..'
alias ....=...

# this will print out the input string in the form of "cmd - desc"
function printHelp(){

  regex='\s*(.+?)\s*->\s*(.*)'
  if [[ "$1" =~ $regex ]]; then

    # figure out how much whitespace between cmd and desc should have
    len=${#BASH_REMATCH[1]}
    sep=$'\t\t'
    if [ $len -lt 8 ]; then
      sep=$'\t\t\t'
    elif [ $len -ge 16 ]; then
      sep=$'\t'
    fi

    echo "${BASH_REMATCH[1]}${sep}${BASH_REMATCH[2]}"

  fi

}

#? help -> print this help menu
function help(){

  echo -e "${BLUE}= = = = = = Useful Commands${NONE}"

  printHelp "cd - -> go to the previous directory (similar to pop)"

  # http://stackoverflow.com/a/68429/5006
  printHelp "sudo !! -> run the last command, but with sudo"

  # http://stackoverflow.com/a/171938/5006
  printHelp "ls -d */ -> list only subdirectories of the current dir"

  # http://www.cyberciti.biz/faq/redirecting-stderr-to-stdout/
  # http://www.cyberciti.biz/faq/how-to-redirect-output-and-errors-to-devnull/
  printHelp "cmd &> file -> pipe the cmd stderr output to a file"
  printHelp "cmd > file 2>&1 -> pipe all cmd output to a file or /dev/null"
  
  # http://www.cyberciti.biz/tips/linux-debian-package-management-cheat-sheet.html
  printHelp "dpkg -L <NAME> -> list files owned by the installed package NAME"
  printHelp "dpkg -l <NAME> -> list packages related to NAME"
  printHelp "dpkg -S <FILE> -> what packages owns FILE"
  printHelp "dpkg -s <NAME> -> get info about package NAME"
  printHelp "apt-cache search <NAME> -> search packages related to NAME"
  printHelp "apt-cache depends <NAME> -> list dependencies of package NAME"

  # we self document these files
  bashfiles=(~/.bash_aliases ~/.bash_adhoc)
  for bashfile in "${bashfiles[@]}"; do

    if [ -f $bashfile ]; then

      echo ""
      echo -e "${BLUE}= = = = = = $bashfile${NONE}"

      #we want to run the command and only split the string on newlines, not all whitespace
      # the $'\n' makes it so the newline is interpretted correctly
      IFS=$'\n'
      helplines=(`cat "$bashfile" | grep "#?"`)
      unset IFS

      # this will loop through each item in the array
      for line in "${helplines[@]}"; do

        if [ "${line:0:2}" == "#?" ]; then

          printHelp "${line:2}"

        fi

      done

    fi

  done

  # http://noopsi.com/item/11479/quick_reference_keyboard_shortcuts_cli_linux_learned/
  # http://stackoverflow.com/questions/68372/what-is-your-single-most-favorite-command-line-trick-using-bash
  # http://www.hypexr.org/bash_tutorial.php#emacs
  # http://www.catonmat.net/blog/the-definitive-guide-to-bash-command-line-history/
  echo ""
  echo -e "${BLUE}= = = = = = Bash shell keyboard shortcuts${NONE}"
  echo $'bind -p\t\tshow all keyboard shorcuts'
  echo $'ctrl-a\t\tMove cursor to the beginning of the input line.'
  echo $'ctrl-e\t\tMove cursor to the end of the input line.'
  echo $'alt-b\t\tMove cursor back one word'
  echo $'alt-f\t\tMove cursor forward one word'
  echo ""
  echo $'ctrl-p\t\tup arrow'
  echo $'ctrl-n\t\tdown arrow'
  echo ""
  echo $'ctrl-w\t\tCut the last word'
  # A combination of ctrl-u to cut the line combined with ctrl-y can be very helpful. 
  # If you are in middle of typing a command and need to return to the prompt to retrieve 
  # more information you can use ctrl-u to save what you have typed in and after you 
  # retrieve the needed information ctrl-y will recover what was cut.
  echo $'ctrl-u\t\tCut everything before the cursor'
  echo $'ctrl-d\t\tSame as [DEL] (this is the Emacs equivalent).'
  echo $'ctrl-k\t\tCut everything after the cursor'
  echo $'ctrl-l\t\tClear the terminal screen.'
  echo $'ctrl-y\t\tPaste, at the cursor, the last thing to be cut'
  echo $'ctrl-_\t\tUndo the last thing typed on this command line'
  echo ""
  echo $'ctrl-t\t\tSwaps last 2 typed characters'
  echo $'ctrl-r <text>\tsearch history for <text>'
  echo $'ctrl-L\t\tClears the Screen, similar to the clear command'
  echo ""
  echo $'set -o emacs\tSet emacs mode in Bash (default)'
  echo $'set -o vi\tSet vi mode in Bash (initially in insert mode)'
  echo ""
  echo -e "${BLUE}= = = = = = Tips${NONE}"
  # http://www.unix.com/ubuntu/81380-how-goto-end-file.html
  echo "less - shift-g to move to the end of a file" 

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

# this will set the prompt to red if the last command failed, and green if it succeeded
# https://wiki.archlinux.org/index.php/Color_Bash_Prompt
ORIG_PS1=$PS1
PROMPT_COMMAND='RET=$?;'
RET_COLOR='$(if [[ $RET = 0 ]]; then echo -ne "\[$GREEN\]"; else echo -ne "\[$RED\]"; fi;)'
PS1="$RET_COLOR$ORIG_PS1\[$NONE\]"

# include the bash_adhoc file
# basically, since this file is now generic, I needed a new place to put custom
# methods that are for a particular box
if [ -f ~/.bash_adhoc ]; then
    . ~/.bash_adhoc
fi
