#! /bin/sh
### BEGIN INIT INFO
# Provides:          Venv launch for Python 
# Required-Start:    networking
# Required-Stop:     networking
# Default-Start:     2 3 4 5
# Default-Stop:      S 0 1 6
# Short-Description: Starts gunicorn server
# Description:       Starts gunicorn server
### END INIT INFO

set -e

SITES_PATH=/home/geo/pyapps/geo
ENVIRONMENT_PATH=$SITES_PATH/environment
RUNFILES_PATH=/var/run/geo
RUN_AS=geo
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DESC="Gunicorn Geo Server"
NAME=$0
SCRIPTNAME=/etc/init.d/$NAME
ACTIVATE=$SITES_PATH/bin/activate
GUNICORN=$SITES_PATH/bin/gunicorn
SERVER_DIR=$SITES_PATH/app/geolocator
SITE="Geo"

mkdir -p $RUNFILES_PATH
chown -R $RUN_AS:$RUN_AS $RUNFILES_PATH

#
#       Function that starts the daemon/service.
#
d_start()
{
    # Starting Server
    echo -n " $SITE"

    if [ -f $RUNFILES_PATH/$SITE.pid ]; then
        echo -n " already running"
    else
        . $ACTIVATE
        start-stop-daemon --start --quiet \
                   --pidfile $RUNFILES_PATH/$SITE.pid \
                   --chuid $RUN_AS --exec $GUNICORN -- \
                   -b 0.0.0.0:7070 \
                   -p $RUNFILES_PATH/$SITE.pid \
                   -w 2 \
                   --chdir $SERVER_DIR \
                   -D \
                   server:api
    fi
    sleep 1
}

#
#       Function that stops the daemon/service.
#
d_stop() {
    # Kill Server
    echo -n " $SITE"
    start-stop-daemon --stop --quiet --pidfile $RUNFILES_PATH/$SITE.pid \
                      || echo -n " not running"
    if [ -f $RUNFILES_PATH/$SITE.pid ]; then
       rm -f $RUNFILES_PATH/$SITE.pid
    fi
    sleep 1
}

ACTION="$1"
case "$ACTION" in
    start)
        echo -n "Starting $DESC:"
        d_start
        echo "."
        ;;

    stop)
        echo -n "Stopping $DESC:"
        d_stop
        echo "."
        ;;

    status)
        echo "Status of $DESC:"
        echo -n "  $SITE"
        if [ -f $RUNFILES_PATH/$SITE.pid ]; then
            echo " running ($(cat $RUNFILES_PATH/$SITE.pid))"
        else
            echo " not running"
        fi
        ;;

    restart|force-reload)
        echo -n "Restarting $DESC: $NAME"
        d_stop
        sleep 2
        d_start
        echo "."
        ;;

    *)
        echo "Usage: $NAME {start|stop|restart|force-reload|status} [site]" >&2
        exit 3
        ;;
esac

exit 0