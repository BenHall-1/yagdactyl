#!/bin/sh

echo 'Begin Docker init script'
# avoid hard-coded usernames in entry script
myName="container"
HOME="/home/$myName"

echo 'Moving YAGPDB'
cp /home/yagpdb $HOME/yagpdb
chown container:container /home/container/yagpdb
echo 'Moved YAGPDB'

echo 'Checking all environment variables...'
printenv

# put the -all fix here
echo 'All good'
yagBin="$HOME/yagpdb"
if [[ $# -gt 0 ]]; then
    # CMD is not empty
    echo 'Reading CMD'
    if [[ "$1" == '/app/yagpdb' || "$1" == 'yagpdb' ]]; then
        # wrong path
        echo 'Wrong path corrected. Running yagpdb with CMD as parameters'
        # discard $1
        shift
        exec $yagBin "$@"
    elif ! [[ -f $1 ]]; then
        # $1 is not a regular file, assume it's yagpdb's parameter
        # if $1 exists but not executable... idk not my business?
        echo 'Running yagpdb with CMD as parameters'
        exec $yagBin "$@"
    else
        echo 'Running CMD'
        exec "$@"
    fi
else
    echo 'Running yagpdb -all'
    exec $yagBin -all -exthttps=false -https=false
fi