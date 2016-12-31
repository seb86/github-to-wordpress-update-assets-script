# Github to WordPress.org Plugin Assets Updater Script
Sometimes you just want to update the assets for your WordPress plugin either it be the banner, the icon or the screenshots. This allows you to do that.

This script is dummy proof. No need to configure anything. Just run the script and follow the instructions as you go along.

## What does the script do?
This script will pull down your remote GIT and the SVN you want to update, copy the assets and commit it to WordPress.org.

Before or that it asks a few questions to setup the process of the script such as the ROOT Path of the plugin your GitHub username, repository slug, assets location and so on.

To use it you must:

1. Host your code on GitHub
2. Already have a WordPress.org SVN repository setup for your plugin.
3. Have both GIT and SVN setup on your machine and available from the command line.

## Getting started

All you have to do is download the script assets.sh from this repository and place it in a location of your choosing.

## Usage

1. Open up terminal and cd to the directory containing the script.
2. Run: ```sh assets.sh```
3. Follow the prompts.

## Final notes

- This will checkout the remote version of your assets from your Github Repo.
- I have tested this on Mac only.
- Use at your own risk of course :)
