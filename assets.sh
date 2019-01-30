#!/bin/sh

clear

# ASK INFO
echo "---------------------------------------------------------------------"
echo "                WordPress.org Plugin Assets Updater                  "
echo "---------------------------------------------------------------------"
read -p "Enter the ROOT PATH of the plugin you want to update: " ROOT_PATH

if [[ -d $ROOT_PATH ]]; then
	echo "---------------------------------------------------------------------"
	echo "New ROOT PATH has been set."
	cd $ROOT_PATH
elif [[ -f $ROOT_PATH ]]; then
	echo "---------------------------------------------------------------------"
	read -p "$ROOT_PATH is a file. Please enter a ROOT PATH: " ROOT_PATH
fi

echo "---------------------------------------------------------------------"
read -p "Enter the WordPress plugin slug: " SVN_REPO_SLUG
echo "---------------------------------------------------------------------"
clear

echo "---------------------------------------------------------------------"
echo "Now processing..."
echo "---------------------------------------------------------------------"

SVN_REPO_URL="https://plugins.svn.wordpress.org"

# Set WordPress.org Plugin URL
SVN_REPO=$SVN_REPO_URL"/"$SVN_REPO_SLUG"/assets/"

# Set temporary SVN folder for WordPress.
TEMP_SVN_REPO=${SVN_REPO_SLUG}"-svn"

# Delete old SVN cache just incase it was not cleaned before after the last release.
rm -Rf $ROOT_PATH$TEMP_SVN_REPO

# CHECKOUT SVN DIR IF NOT EXISTS
if [[ ! -d $TEMP_SVN_REPO ]]; then
	echo "Checking out WordPress.org plugin assets."
	svn checkout $SVN_REPO $TEMP_SVN_REPO || { echo "Unable to checkout repo."; exit 1; }
fi

echo "---------------------------------------------------------------------"
read -p "Enter your GitHub username: " GITHUB_USER
echo "---------------------------------------------------------------------"
read -p "Enter repository slug: " GITHUB_REPO_NAME
clear

# Set temporary folder for GitHub.
TEMP_GITHUB_REPO=${GITHUB_REPO_NAME}"-git"

# Delete old GitHub cache just incase it was not cleaned before after the last release.
rm -Rf $ROOT_PATH$TEMP_GITHUB_REPO

echo "---------------------------------------------------------------------"
echo "Is the line secure?"
echo "---------------------------------------------------------------------"
echo " - y for SSH"
echo " - n for HTTPS"
read -p "" SECURE_LINE

# Set GitHub Repository URL
if [[ ${SECURE_LINE} = "y" ]]; then
	GIT_REPO="git@github.com:"${GITHUB_USER}"/"${GITHUB_REPO_NAME}".git"
else
	GIT_REPO="https://github.com/"${GITHUB_USER}"/"${GITHUB_REPO_NAME}".git"
fi;

clear

# Clone Git repository
echo "---------------------------------------------------------------------"
echo "Cloning GIT repository from GitHub"
echo "---------------------------------------------------------------------"
git clone --progress $GIT_REPO $TEMP_GITHUB_REPO || { echo "Unable to clone repo."; exit 1; }

# Move into the temporary GitHub folder
cd $ROOT_PATH$TEMP_GITHUB_REPO
clear

# Which remote?
echo "---------------------------------------------------------------------"
read -p "Which remote are we fetching? Default is 'origin'" ORIGIN
echo "---------------------------------------------------------------------"

# IF REMOTE WAS LEFT EMPTY THEN FETCH ORIGIN BY DEFAULT
if [[ -z ${ORIGIN} ]]; then
	git fetch origin

	# Set ORIGIN as origin if left blank
	ORIGIN=origin
else
	git fetch ${ORIGIN}
fi;

# List Branches
echo "---------------------------------------------------------------------"
git branch -r || { echo "Unable to list branches."; exit 1; }
echo "---------------------------------------------------------------------"
read -p "Which branch contains the updated asset files? /" BRANCH

# Switch Branch
echo "---------------------------------------------------------------------"
echo "Switching to branch " ${BRANCH}

# IF BRANCH WAS LEFT EMPTY THEN FETCH "master" BY DEFAULT
if [[ -z ${BRANCH} ]]; then
	BRANCH=master
else
	git checkout ${BRANCH} || { echo "Unable to checkout branch."; exit 1; }
fi;

# Remove unwanted files and folders
echo "---------------------------------------------------------------------"
echo "Removing unwanted files..."
echo "---------------------------------------------------------------------"
rm -Rf .git
rm -Rf .github
rm -Rf tests
rm -Rf apigen
rm -Rf node_modules
rm -f .gitattributes
rm -f .gitignore
rm -f .gitmodules
rm -f .jscrsrc
rm -f .jshintrc
rm -f phpunit.xml.dist
rm -f .editorconfig
rm -f *.lock
rm -f *.rb
rm -f *.js
rm -f *.json
rm -f *.xml
rm -f *.md
rm -f *.yml
rm -f *.neon
rm -f *.jpg
rm -f *.sh
rm -f *.php
rm -f *.txt

read -p "Directory where the assets are stored in the repository: " ASSETS_FOLDER

# Copy GitHub asset files to SVN temporary folder.
cp -prv -f -R ${ASSETS_FOLDER}"/." "../"${TEMP_SVN_REPO}"/"

# Move into the SVN temporary folder
cd "../"${TEMP_SVN_REPO}

# Update SVN
echo "---------------------------------------------------------------------"
echo "Updating SVN"
svn update || { echo "Unable to update SVN."; exit 1; }

# Add all asset files.
svn add --force *

# SVN Commit
echo "---------------------------------------------------------------------"
echo "Getting SVN Status."
svn status --show-updates

# Deploy Update
echo "---------------------------------------------------------------------"
echo "Committing assets to WordPress.org..."
svn commit -m "Updated assets for "${SVN_REPO_SLUG}"" || {
echo "---------------------------------------------------------------------"
	echo "Unable to commit. Loading last log.";
	svn log -l 1
	exit 1;
}

echo "---------------------------------------------------------------------"
read -p "Asset files were updated. Press [ENTER] to clean up."
clear

# Remove the temporary directories
echo "---------------------------------------------------------------------"
echo "Cleaning Up..."
echo "---------------------------------------------------------------------"
cd "../"
rm -Rf $ROOT_PATH$TEMP_GITHUB_REPO
rm -Rf $ROOT_PATH$TEMP_SVN_REPO

# Done
echo "Update Done."
echo "---------------------------------------------------------------------"
read -p "Press [ENTER] to close program."

clear
