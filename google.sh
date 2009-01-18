VAR=$(pwd)
cd ~/lib/sb/strongbox/trunk
git fetch ~/lib/Strongbox
git branch tmp $(cut -b-40 .git/FETCH_HEAD)
git tag -a -m "Last fetch" newlast tmp
git rebase --onto master last tmp
git branch -M tmp master
git svn dcommit
mv .git/refs/tags/newlast .git/refs/tags/last
cd $VAR
