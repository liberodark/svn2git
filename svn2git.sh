#!/bin/bash
#
# About: SVN to Git
# Author: liberodark
# Thanks : 
# License: GNU GPLv3

version="0.0.2"

echo "Welcome on Svn2Git Script $version"

#=================================================
# ASK
#=================================================

echo "What is your svn projet NAME ?"
read -r ASK_SVN_NAME

echo "What is your git URL ?"
read -r ASK_GIT_REPO_URL

echo "What is your svn URL ?"
read -r ASK_SVN_REPO_URL

echo "What is your svn USER ?"
read -r ASK_SVN_USER

svn2git_1(){
#GIT_NAME="${ASK_GIT_NAME}"
GIT_REPO_URL="${ASK_GIT_REPO_URL}"
GIT_REPO_PATH="${ASK_SVN_NAME}/.git"
SVN_PROJECT_URL="${ASK_SVN_REPO_URL}"

subgit configure --layout auto "$SVN_PROJECT_URL" "$GIT_REPO_PATH"

# Optional
nano "$GIT_REPO_PATH/subgit/authors.txt"
#nano "$GIT_REPO_PATH/subgit/config"

subgit install "$GIT_REPO_PATH"
subgit import "$GIT_REPO_PATH"

cd "$GIT_REPO_PATH" || exit
git remote add origin "$GIT_REPO_URL"
git push --all origin
git push --tags origin
}

svn2git_2(){
#GIT_NAME="${ASK_GIT_NAME}"
GIT_REPO_URL="${ASK_GIT_REPO_URL}"
GIT_REPO_PATH="${ASK_SVN_NAME}"
SVN_PROJECT_URL="${ASK_SVN_REPO_URL}"
SVN_USER="${ASK_SVN_USER}"

svn log --quiet "$SVN_PROJECT_URL" | grep -E "r[0-9]+ \| .+ \|" | cut -d'|' -f2 | sed 's/ //g' | sort | uniq > authors.txt
nano authors.txt || exit
git svn clone --authors-file=authors.txt --no-minimize-url --prefix="" --no-metadata -s --user "$SVN_USER" "$SVN_PROJECT_URL"

cd "$GIT_REPO_PATH" || exit

git for-each-ref refs/remotes/tags | cut -d / -f 4- | grep -v @ | while read tagname;
do git tag "$tagname" "tags/$tagname"; git branch -r -d "tags/$tagname";
done

git for-each-ref refs/remotes | cut -d / -f 3- | grep -v @ | while read branchname;
do git branch "$branchname" "refs/remotes/$branchname";
git branch -r -d "$branchname";
done

git branch -d trunk

git remote add origin "$GIT_REPO_URL"
git push --all origin
git push --tags origin
}

#==============================================
# RUN SVN2GIT
#==============================================

while true; do
    read -r -p "Do you want to use subgit ? (y/n) :" yn
    case $yn in
        [Yy]* ) svn2git_1; break;;
        [Nn]* ) svn2git_2; break;;
        * ) echo "Please answer yes or no.";;
    esac
done
