#!/bin/bash

usage_exit() {
    {
        echo "Usage: $0 [-t] [-p ELEMENT-NAME[,..]|*] <xml1> <xml2>"
        echo ""
        echo "options:"
        echo "  -t  diff element content - otherwise only missing elements will be reported"
        echo "  -p  comma-separated list of element names which should be compared with strict positioning. The default is not to care about the position of a child element under its parent, but either it exists or not. If the value for -p is '*', then all document elements will be compared with strict positioning turned on"
    } 1>&2
    
    exit 1
}

diff=0
strict_positioning=

while getopts p:th OPT; do
    case $OPT in
        t) diff=1;;
        p) strict_positioning="$OPTARG";;
        h|\?) usage_exit;;
    esac
done

shift $((OPTIND - 1))

test $# -eq 2 || usage_exit

xsltproc --stringparam compare "$2" --stringparam strict-positioning "$strict_positioning" --param text-diff $diff $(dirname $0)/xmlcomp.xsl "$1"
