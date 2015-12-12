#!/bin/bash

lollipop_path=${HOME}/project/geekbox/Lollipop
repo_prefix=lollipop
github_urlbase=git@github.com:geekboxzone

# clone the init repository first
install -dv $lollipop_path
cd $lollipop_path
if [ -d "$lollipop_path/.git" ]; then
	git pull origin
else
	git clone $github_urlbase/lollipop $lollipop_path
fi

# convert "/" to "_"
cat ./project.list > /tmp/project.path
sed -i "s/\//_/g" /tmp/project.path

# clone all the other repositories
for repo_path in `cat ./project.list`
do
	let ++i
	repo_name=`awk 'NR=='$i'' /tmp/project.path`
	github_reponame="$repo_prefix"_"$repo_name"
	repo_remoteurl=$github_urlbase/$github_reponame
	echo "<$i> path: $repo_path"
	if [ -d "$repo_path/.git" ]; then
		# exist: pull to sync
		cd $repo_path
		git pull origin
		cd -
	else
		# empty: clone to create
		git clone $repo_remoteurl $repo_path
	fi
	echo "--------------------------------------------"
done
