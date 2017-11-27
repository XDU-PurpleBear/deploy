#!/bin/sh

function logError() {
    # log the error into stderr
    echo $@ >&2
    return 1
}

function logErrorW() {
    # log error when exit code /= 0
    if [ $? -ne 0 ]; then
        logError $@
        exit 1
    fi
}

function logInfo() {
    # log the info into stdout
    echo [`date`] $@
}

function checkBin() {
    logInfo Checking $1
    which $1 > /dev/null
    if [ $? -eq 0 ]; then
        logInfo Find $1 as `which $1`
        return 0
    else
        return 1
    fi
}

function checkOS() {
    # should call via source
    # check the system
    SYS_KERNEL=`uname`
    logInfo Checking OS
    if [ x"$SYS_KERNEL" = "xLinux" ]; then
        logInfo use Linux
    elif [ x"$SYS_KERNEL" = "xDarwin" ]; then
        logInfo use macOS
    elif [[ x"$SYS_KERNEL" == *NT* ]]; then
        logInfo use Windows NT
    else
        logError $SYS_KERNEL system do not support
    fi
}

# Checking OS
checkOS

# Checking Docker
checkBin docker
logErrorW Please install docker

# Checking python2
checkBin python
logErrorW Please install python 2.7

# Checking pip
checkBin pip
logErrorW Please install pip for python 2.7

# Checking npm
checkBin npm
logErrorW Please install npm

logInfo create tmp dir
mkdir tmp

logInfo Deploy database (with Docker)
logInfo pull docker images
docker pull postgres:latest
docker pull redis:latest
docker pull qinka/pb-database:pb-auth-latest

logInfo create servers
logInfo create pb-db
docker run -d --name pb-db -p 5432:5432 -e POSTGRES_PASSWORD=12345qwert postgres:latest
wget https://raw.githubusercontent.com/XDU-PurpleBear/database/master/sql/initialization.sql -O tmp/init.sql
docker cp tmp/init.sql PB-DB:/
docker exec pb-db psql -d postgres -U postgres -f /init.sql
logInfo create pb-redis
docker run -d --name pb-redis -p 6379:6379 redis:latest
logInfo create pb-auth
docker run -d --name pb-auth --link pb-redis:redis -p 3000:3000 qinka/pb-database:pb-auth:latest -c "pb-auth 3000 redis 6379"

logInfo compile front end
git clone https://github.com/XDU-PurpleBear/frontend.git tmp/frontend
ROOT_DIR=`pwd`
cd tmp/frontend
npm install
npm run build

logInfo compile back end
cd $PWD
git clone https://github.com/XDU-PurpleBear/backend.git tmp/backend
pip install flask psycopg2
cp tmp/frontend/build/build/bundle.js tmp/backend/final_release/static
cd tmp/backend
python tmp/backend/final_release/main.py
