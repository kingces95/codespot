#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -e 

# Treat unset variables as an error when substituting.
set -u  

# Print commands and their arguments as they are executed.
# set -x

# if stderr is tty, point it at a log file instead
if test -t 2
then
    # clear log
    : > $LogFile

    # make echos to stderr append the log
    exec 2>> $LogFile
fi