git-backup
==========

Automaticly backup the specific Github repositories and/or branches.

deployment
-------------

1. Install git and Initiate local repository; E.g:
>> _yum install git_

>> _mkdir -p /git-backup/scripts_

>> _cd /git-backup/scripts_

>> _git init_

>> _git colone git@github.com:xiaojias/git-backup.git_

>> _mv ./git-backup/\*  /git-backup/scripts/_ 

2. Add to-be-backedup repository and branch into configuration file; E.g:
>> _vim repo-branch-config.txt_

3. Clone the to-be-backedup reposigory into local repository;

4. Create jobs in crontab; The jobs are similar to:
>> _crontab -l_

>> _10 0 * * * /bin/sh /git-backup/scripts/git-backup-daily.sh 2>&1_

>> _15 0 1 * * /bin/sh /git-backup/scripts/git-backup-monthly.sh 2>&1_

Constraints
-----------
1. Organization name is hard code in Clone-repo.sh script.





