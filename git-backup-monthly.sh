#!/bin/sh
scriptDir="/git-backup/scripts"
outDir="/git-backup/data"

cd $scriptDir
./Clone-repo.sh $scriptDir/repo-branch-config.txt $outDir > /tmp/Clone-repo.log 2>&1
