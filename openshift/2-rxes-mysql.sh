#!/usr/bin/env bash
set -e

eval $(minishift docker-env)

# Colors are important
export RED='\033[0;31m'
export NC='\033[0m' # No Color
export YELLOW='\033[0;33m'
export BLUE='\033[0;34m'

export OS_PROJECT_NAME="reactive-data-stream"

function warning {
    echo -e "  ${RED} $1 ${NC}"
}

function info {
    echo -e "  ${BLUE} $1 ${NC}"
}

oc version

if oc new-project "${OS_PROJECT_NAME}"; then
    info "Project ${OS_PROJECT_NAME} created"
else
    info "Reusing existing project ${OS_PROJECT_NAME}"
    oc project "${OS_PROJECT_NAME}"
fi

cd "../compose/rxes-mysql" || exit
docker build -t rxes/mysql .
info "MySQL built"

oc new-app --name=mysql rxes/mysql
oc env dc/mysql MYSQL_ROOT_PASSWORD=debezium  MYSQL_USER=my-user MYSQL_PASSWORD=password
oc patch dc mysql -p '{"spec": {"template": {"spec": {"containers": [{"name": "mysql", "imagePullPolicy":"IfNotPresent"}]}}}}'
info "MySQL deployed"