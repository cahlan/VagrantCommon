#! /bin/sh
# custom init.d script for uwsgi
# based on skeleton from Debian GNU/Linux found at http://homepage.hispeed.ch/py430/python/daemon
#
# jay@marcyes.com

DAEMON=/usr/local/bin/uwsgi
NAME=uwsgi
APPS_DIR="/etc/uwsgi/apps-enabled"

test -f $DAEMON || exit 0

# Exit immediately if a command exits with a non-zero status.
set -e

# returns whether the passed in pid file is still running
# you can use this with -n and -z of test, it will echo the pid if it is still running, or
# be an empty length string if it isn't running 
is_running(){

  if [ -f "$1" ]; then
  
    pid=$(cat $1)
    ps -eo pid | grep $pid
    
  fi
  
}

# kill the running processes tied to the passed in pid file, wait until it is killed
do_stop(){

  if [ -n "$(is_running $1)" ]; then
  
    pid=$(cat $1)
    $DAEMON --stop $1
  
    until [ -z "$(is_running $1)" ]; do
      sleep 1
    done
  
  fi

}

# start up a uwsgi server instance for each conf file found 
for f in $(ls $APPS_DIR/*); do
  if [ -f $f ]; then
  
    # parse up the configuration file so we know what we're dealing with
    # http://stackoverflow.com/questions/965053/
    filename=$(basename $f)
    ext=${filename##*.}
    filename=${filename%.*}
    log="/var/log/uwsgi/$filename.log"
    pid="/var/run/$filename.pid"
    
    start_cmd="$DAEMON --$ext $f --daemonize $log --pidfile $pid"
    reload_cmd="$DAEMON --reload $pid"

    case "$1" in
      
      start)
      
      echo -n "Starting $NAME - $filename: "
      $start_cmd
      echo "done."
      ;;
      
      stop)
      echo -n "Stopping $NAME - $filename: "
      do_stop $pid
      echo "done."
      ;;
      
      reload|force-reload)
      echo -n "Reloading $NAME - $filename: "
      if [ -n "$(is_running $1)" ]; then
        $reload_cmd
      else
        $start_cmd
      fi
      echo "done."
      ;;
      
      restart)
      echo -n "Restarting $NAME - $filename: "
      do_stop $pid
      $start_cmd
      echo "done."
      ;;
      
      *)    
      n=/etc/init.d/$NAME
      echo "Usage: $n {start|stop|restart|reload|force-reload}" >&2
      exit 1
      ;;
        
    esac
  fi
done

exit 0
