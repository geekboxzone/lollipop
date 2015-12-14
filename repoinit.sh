#!/bin/bash

lollipop_path=${HOME}/project/geekbox/Lollipop
repo_prefix=lollipop
github_urlbase=https://github.com/geekboxzone
MAXTRYNUM=3
reponum=1
trynum=1

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
REPONUMS=`wc -l ./project.list | cut -d" " -f1`
while [ "$reponum" -le "$REPONUMS" ]; do
	repo_path=`awk 'NR=='$reponum'' ./project.list`
	repo_name=`awk 'NR=='$reponum'' /tmp/project.path`
	github_reponame="$repo_prefix"_"$repo_name"
	repo_remoteurl=$github_urlbase/$github_reponame
	if [ -d "$repo_path/.git" ]; then
		# exist: pull to sync
		cd $repo_path
		git pull origin
		cd $lollipop_path
	else
		# empty: clone to create
		git clone $repo_remoteurl $repo_path 2>/dev/null
	fi

	# Check completed or not
	cd $repo_path
	local_commitid=`git log -n1 --pretty=oneline | awk '{print $1}'`
	remote_commitid=`git log -n1 --pretty=oneline origin/geekbox | awk '{print $1}'`
	cd $lollipop_path
	if [ "$local_commitid" = "$remote_commitid" -a -n "$local_commitid" ]; then
		echo "-------------->[$reponum]Done: $repo_name"
		let ++reponum
		continue
	else
		echo "Fail to clone: $repo_name [$trynum] times!"
		let ++trynum
		rm -rf $repo_path
		if [ $trynum -gt $MAXTRYNUM ]; then
			echo "Exit to try! you need clone this repository by manual."
			echo "Then fix <reponum=$reponum> to continue."
			break;
		fi
	fi
done


# Special repository
# the default name is too long, so we cut off the tail-part
# 100 characters limited by Github
git clone $github_urlbase/lollipop_external_chromium_org_third_party_eyesfree_src_android_java_src_com_googlecode_eyesfree_bra external/chromium_org/third_party/eyesfree/src/android/java/src/com/googlecode/eyesfree/braille


# Large file repositories
# 100MB limited by Github
# TODO: github LSF
android_urlbase=https://android.googlesource.com
git clone $android_urlbase/platform/external/eclipse-basebuilder -b android-5.1.0_r3 external/eclipse-basebuilder
git clone $android_urlbase/platform/prebuilts/clang/linux-x86/host/3.4 -b android-5.1.0_r3 prebuilts/clang/linux-x86/host/3.4
git clone $android_urlbase/platform/prebuilts/clang/linux-x86/host/3.5 -b android-5.1.0_r3 prebuilts/clang/linux-x86/host/3.5
git clone $android_urlbase/platform/prebuilts/sdk -b android-5.1.0_r3 prebuilts/sdk
git clone $android_urlbase/platform/prebuilts/eclipse -b android-5.1.0_r3 prebuilts/eclipse
git clone $android_urlbase/device/htc/flounder-kernel -b android-5.1.0_r3 device/htc/flounder-kernel
git clone $android_urlbase/device/moto/shamu-kernel -b android-5.1.0_r3 device/moto/shamu-kernel
git clone $android_urlbase/platform/prebuilts/android-emulator -b android-5.1.0_r3 prebuilts/android-emulator
git clone $android_urlbase/platform/prebuilts/qemu-kernel -b android-5.1.0_r3 rebuilts/qemu-kernel
