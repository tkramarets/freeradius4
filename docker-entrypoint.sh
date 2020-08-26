#!/bin/sh
set -e

# this if will check if the first argument is a flag
# but only works if all arguments require a hyphenated flag
# -v; -SL; -f arg; etc will work, but not arg1 arg2
if [ "$#" -eq 0 ] || [ "${1#-}" != "$1" ]; then
    chown freerad:freerad -R /etc/freeradius
    if [ -z "${RAD_DEBUG}" ]
    then
    set -- freeradius "$@"
    else
    set -- freeradius ${RAD_DEBUG_LEVEL} "$@"
fi
fi

# check for the expected command
if [ "$1" = 'freeradius' ]; then
    shift
    chown freerad:freerad -R /etc/freeradius
    if [ -z "${RAD_DEBUG}" ]
    then
    set -- freeradius -f "$@"
    else
    set -- freeradius -f ${RAD_DEBUG_LEVEL} "$@"
fi
fi

# many people are likely to call "radiusd" as well, so allow that
if [ "$1" = 'radiusd' ]; then
    shift
    chown freerad:freerad -R /etc/freeradius
    if [ -z "${RAD_DEBUG}" ]
    then
    set -- freeradius -f "$@"
    else
    set -- freeradius -f ${RAD_DEBUG_LEVEL} "$@"
fi
fi

# else default to run whatever the user wanted like "bash" or "sh"
exec "$@"
