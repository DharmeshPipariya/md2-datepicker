#!/bin/bash
set -e # Exit with nonzero exit code if anything fails

SOURCE_BRANCH="master"
TARGET_BRANCH="gh-pages"
COMMIT_MSG=`git log --format=%B --no-merges -n 1`

# Pull requests and commits to other branches shouldn't try to deploy, just build to verify
if [ "$TRAVIS_PULL_REQUEST" != "false" ] || [ "$TRAVIS_BRANCH" != "$SOURCE_BRANCH" ] || [[ $COMMIT_MSG != "deploy-"* ]]; then
  echo "Building demo-app"
  gulp build:devapp
  exit 0
fi

# Save some useful information
SHA=`git rev-parse --verify HEAD`

# Clone the existing gh-pages for this repo into deploy/
git clone https://dharmeshpipariya:$GH_TOKEN@github.com/dharmeshpipariya/md2-datepicker.git --branch=gh-pages deploy

# Clean deploy existing contents
rm -rf deploy/**/* || exit 0

# Deploy demo.
gulp deploy

# Configure cloned repo.
cd deploy
git config --global user.email "pipariyadharmesh@gmail.com"
git config --global user.name "Dharmesh Pipariya"

# Check if there are any changes or not.
if [ -z `git diff --exit-code` ]; then
  echo "Demo already updated."
  exit 0
fi

# Commit changes and Push Demo
git add -A .
git commit -m "Update demo: ${SHA}"
git push origin $TARGET_BRANCH
echo "Demo deployed"