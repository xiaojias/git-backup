#!/bin/sh
###################################################################################
# Export-branch.sh
# Export a Remote branch as external files, and store the files under a directory

# Usage: Export-branch.sh <branch_name> <out_dir>
# Examples:
# ../git-backup/Export-branch.sh development /tmp
#
# 20180213:XJS : Initial
###################################################################################

branchName=$1
outputDirectory=$2/${branchName}
preFix=`date +%Y-%m-%d/`
tempBranch=${preFix}-${branchName}

#################################
# check connection
git status
if [ $? != 0 ];then
   echo "Failed to connect git repository"
   exit 1
fi

#################################
# check the branch
remoteName=`git remote -v|grep "(fetch)"|awk -F" " '{ print $1 }'`

returnCode=`git branch -a|grep "${remoteName}/${branchName}"|wc -l`
if [ $returnCode == 0 ]; then
   echo "Failed: $branchName is not existing"
   exit 1
fi

#################################
# Store the current branch
curBranch=`git status|grep "^# On branch "|sed 's/# On branch //'`

#################################
# create a temporary branch to store the pulling data
git checkout -b $tempBranch
git pull ${remoteName} ${branchName}:${tempBranch}
git checkout $curBranch

#################################
# Export the branch as external files
if [ ! -d $outputDirectory ]; then
   mkdir -p $outputDirectory
fi

git archive --format=tar --prefix=${preFix} ${tempBranch} |(cd $outputDirectory && tar -xf -)
if [ $? != 0 ];then
   echo "Failed to export for $branchName"
   exit 1
fi

#################################
# delete temporary branch
git branch -D $tempBranch 

# end of program
#################################################

