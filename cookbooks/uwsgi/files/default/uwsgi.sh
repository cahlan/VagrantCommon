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
    stop_cmd="$DAEMON --stop $pid"
    reload_cmd="$DAEMON --reload $pid"

    case "$1" in
      
      start)
      
      echo -n "Starting $NAME - $filename: "
      $start_cmd
      echo "done."
      ;;
      
      stop)
      echo -n "Stopping $NAME - $filename: "
      if [ -f "$pid" ]; then
        $stop_cmd
      fi
      echo "done."
      ;;
      
      reload|force-reload)
      echo -n "Reloading $NAME - $filename: "
      if [ -f "$pid" ]; then
        $reload_cmd
      else
        $start_cmd
      fi
      echo "done."
      ;;
      
      restart)
      if [ -f "$pid" ]; then
        echo -n "Restarting $NAME - $filename: "
        $stop_cmd
        sleep 1
      fi
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
