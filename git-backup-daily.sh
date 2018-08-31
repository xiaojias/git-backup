#!/bin/sh
scriptDir="/git-backup/scripts"
outDir="/git-backup/data"

cd $scriptDir
./Export-repo.sh $scriptDir/repo-branch-config.txt $outDir > /tmp/Export-repo.log 2>&1

