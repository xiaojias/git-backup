#!/bin/sh
###################################################################################
# Export-repo.sh
# Export the specific repository/s and branches as external files
#
# Usage: Export-repo.sh <config_file> <out_dir>
#        1) Read the to-be-exported repository and branches from $config_file;
#        2) Export the data to external files;
#        3) Store the exported directories and files to $out_dir
# For example:
# ../git-backup/Export-repo.sh /tmp/repo-branch-config.txt /tmp
#
# 20180223:XJS : Initial
# 20180227:XJS : Fix the error of "error: pathspec..." and remove debugging messages
###################################################################################

configName=$1
outputTopDirectory=$2
# exact output directory should be $2/<repo>/<branch> for every branch

#################################
# Capture the repo and all its specific branch/es from $configName file,
repoList=`grep -Ev "^$|^[#;]" $configName |awk -F " " '{ print $1 }'|sort -u`

pwdName=`pwd`
#assumption: the repositories are already cloned to the same directory as the script
repoDir=$pwdName

for repoName in `echo $repoList`
do
    cd $pwdName
    echo "Message:Exporting the repo of:$repoName"
    #switch to the repo directory
    cd $repoDir/$repoName

    #################################
    # check connection
    git status
    if [ $? != 0 ];then
       echo "Failed to connect git repository"
       exit 1
    fi

    #get the branch/es
    branchList=`grep -Ev "^$|^[#;]" $configName|grep "^$repoName "|awk -F " " '{ print $2 }'|sort -u|sed 's/,/ /g'`

    if [ -z "$branchList" ]; then
        #get all the remote branches by command
        branchList=`git branch -a|grep "remotes/"|grep -v HEAD|awk -F "/" '{ print $3 }'`
    fi
    for branchName in `echo $branchList`
    do
        echo "Message:Exporting the branch of:$branchName"

        #################################
        # check the branch
        remoteName=`git remote -v|grep "(fetch)"|awk -F" " '{ print $1 }'`
        returnCode=`git branch -a|grep "${remoteName}/${branchName}"|wc -l`
        if [ $returnCode == 0 ]; then
           echo "Failed: $branchName is not existing"
           continue
        fi

        #################################
        # Store the current branch name
        curBranch=`git status|grep "^# On branch "|sed 's/# On branch //'`

        #################################
        # set the name for the temporary branch
        preFix=`date +%Y-%m-%d`
        tempBranch=${preFix}-${branchName}

        # create the temporary branch if necessary, switch to it, and pull the data
        branchYes=`git branch|sed 's/^*//'|sed 's/[ ]*//g'|grep "^$tempBranch$"|wc -l`
        if [ $branchYes == 0 ]; then    # $tempBranch is not existing
            git checkout -b $tempBranch
        else
            if [ "$curBranch" != "$tempBranch" ]; then  # is not on $tempBranch
                git checkout $tempBranch
            fi
        fi
        git reset --hard ${remoteName}/${branchName}   #force to overwrite local branch
        git pull ${remoteName} ${branchName}:${tempBranch}

        if [ "$curBranch" == "$tempBranch" ]; then   #switch to master branch, so that the temporary branch can be removed
            git checkout master
        else
            git checkout $curBranch
        fi

        #################################
        # Export the branch as external files

        #set the exact output directory for the branch
        outputDirectory="${outputTopDirectory}/${repoName}/${branchName}"
        if [ ! -d $outputDirectory ]; then
           mkdir -p $outputDirectory
        fi

        # export all the committed to external files
        git archive --format=tar --prefix="${preFix}/" ${tempBranch} |(cd $outputDirectory && tar -xf -)
        if [ $? != 0 ];then
            echo "Failed to export for branch:$branchName"
        else
            echo "Success to export for branch:$branchName"
        fi

        #################################
        # delete temporary branch
        git checkout master
        git branch -D $tempBranch
    done
done

# end of program
#################################