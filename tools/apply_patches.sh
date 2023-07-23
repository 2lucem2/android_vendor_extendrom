#!/bin/bash
#########################################################################################################
#
# simple patch utility which parses a given directory for *.patch files
# generated by "repo diff > file.patch"
#
# NOTE: do NOT USE "repo diff -u" !!
#
#########################################################################################################
#
# Copyright (C) 2023 steadfasterX <steadfasterX -AT- binbash #DOT# rocks>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#########################################################################################################
#
# a git hard reset before applying is done by default. if you do NOT want to reset before:
# export PATCHER_RESET=false
#
# usage:
# ./apply_patches.sh <full-path-of-patch-dir>
#
#########################################################################################################

# DO NOT set -e !

F_LOG(){
    echo -e "[PATCHER] " "$1"
}

PDIR=$1
[ -z "$PDIR" -o ! -d "$PDIR" ] && echo "ABORT: missing parameter: $0 <patch-dir>" && exit 4
[ -z "$PATCHER_RESET" ] && PATCHER_RESET=true

F_LOG "... detecting patches in: $PDIR"

for p in $(find -L $PDIR -type f -name '*.patch' -exec grep -H project {} \; | sort | tr ' ' '#'); do
    dp=$(basename ${p/:*})
    P=$(echo "$p" | sed 's#^#-i '$(pwd)'/#g;s/:project#/ -d /g')
    F_LOG "... applying >${dp}< within >${p/*#}< now:"
    [ $PATCHER_RESET == "true" ] && repo forall "${p/*#}" -c 'git reset --hard' && echo "git reset hard finished for $p"
    POUT=$(patch -r - --no-backup-if-mismatch --forward --ignore-whitespace --verbose -p1 $P 2>&1)
    ERR=0
    RERR=$?
    # ensure we really fail even when some hunks succeed:
    echo "$POUT" | grep -Eqi "failed" && ERR=3
    F_LOG "... ended with errorcode $ERR"
    if [ $ERR -eq 3 ];then
	echo -e "$POUT" && F_LOG "FATAL ERROR occured while applying >${dp}<!!!" && exit 3
    fi
done