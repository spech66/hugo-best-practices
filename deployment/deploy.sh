#!/bin/sh

# Read the config values
. ./deploy_config

if [ -z "$HUGO_SSH_DESTINATION" ]; then
    echo "HUGO_SSH_DESTINATION is not set correctly";
    exit 1;
else
    echo "Deploying to '$HUGO_SSH_DESTINATION'";
fi

if [ -z "$HUGO_SSH_SERVER" ]; then
    echo "HUGO_SSH_SERVER is not set correctly";
    exit 1;
fi

# Delete existing public folder to avoid old files
rm -rf public

# Build website but exit on error
hugo --minify --gc
if [ $? -ne 0 ]; then
    echo "hugo got errors. exiting.";
    exit 2;
fi

# Sync public folder to destination
# public/ ALWAYS add the slash!!!
rsync --delete -avzh public/ $HUGO_SSH_SERVER:$HUGO_SSH_DESTINATION

exit 0
