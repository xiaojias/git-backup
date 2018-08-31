#!/bin/sh
###################################################################################
# clone-repo.sh
# Clone the specific repository/s
#
# Usage: Clone-repo.sh <config_file> <out_dir>
#        1) Read the to-be-exported repository from $config_file;
#        2) Clone the repositories  to $out_dir
# For example:
# ../git-backup/clone-repo.sh /tmp/repo-branch-config.txt /tmp
#
# 20180227:XJS : Initial
###################################################################################

configName=$1
outputTopDirectory=$2
# the exact output directory should be
orgName='mne'   #works for mne organization only so far

#################################
# Capture the org & repo from $configName file,
repoList=`grep -Ev "^$|^[#;]" $configName |awk -F " " '{ print $1 }'|sort -u`

cd $outputTopDirectory
git init

preFix=`date +%Y-%m-%d`
outputTopDirectory=$outputTopDirectory/$preFix

if [ ! -d $outputTopDirectory ]; then
   mkdir -p $outputTopDirectory
fi

pwdName=`pwd`
for repoName in `echo $repoList`
do
    cd $pwdName
    if [ ! -d $outputTopDirectory/$orgName ]; then   #make the directory for Organization if missing
       mkdir -p $outputTopDirectory/$orgName
    fi

    cd $outputTopDirectory/$orgName
    outputDirectory="${outputTopDirectory}/${orgName}/${repoName}"
    if [ -d $outputDirectory ]; then   #remove the directory for repository if existing
       rm -rf $outputDirectory
    fi

    git clone https://github.ibm.com/${orgName}/${repoName}.git   #clone with https

    if [ $? != 0 ];then
        echo "Failed to clone repository of:${orgName}/${repoName}"
    else
        echo "Success to clone repository of:${orgName}/${repoName}"
    fi
done

# end of program
#################################