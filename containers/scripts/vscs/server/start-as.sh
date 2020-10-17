#!/usr/bin/env bash
user=$1
commit=$2
su -c "./start.sh $commit" $user