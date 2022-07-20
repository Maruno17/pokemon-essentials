# Pokémon Essentials

Based on Essentials v20.1.

You can build your fangame on top of a fork of this repository. Doing so will let you update your fangame with improvements made to this repo as soon as they are made.

## Usage

1. Fork this repo.
2. Get a copy of Essentials v20.1 (a download link cannot be provided here).
3. Clone your forked repo into the Essentials v20.1 folder, replacing the existing files with the ones from the repo.

From here, you can edit this project to turn it into your fangame/develop mods. When this repo is updated, you can pull the changes to update your fork and get the updates into your fangame/modding environment.

## Scripts

The scripts no longer live in the Scripts.rxdata file. They have been extracted into separate files and placed in the Data/Scripts/ folder (and subfolders within). This makes it easier to work with other people and keep track of changes.

The scripts are loaded into the game alphanumerically, starting from the top folder (Data/Scripts/) and going depth-first. That is, all scripts in a given folder are loaded, and then each of its subfolder is checked in turn (again in alphanumerical order) for files/folders to load/check.

### Extracting and reintegrating scripts

This repo contains two script files in the main folder:

* scripts_extract.rb - Run this to extract all scripts from Scripts.rxdata into individual .rb files (any existing individual .rb files are deleted).
  * Scripts.rxdata is backed up to ScriptsBackup.rxdata, and is then replaced with a version that reads the individual .rb files and does nothing else.
* scripts_combine.rb - Run this to reintegrate all the individual .rb files back into Scripts.rxdata.
  * The individual .rb files are left where they are, but they no longer do anything.

You will need Ruby installed to run these scripts. The intention is to replace these with something more user-friendly.

## Files not in the repo

The .gitignore file lists the files that will not be included in this repo. These are:

* The Audio/, Graphics/ and Plugins/ folders and everything in them.
* Everything in the Data/ folder, except for:
  * The Data/Scripts/ folder and everything in there.
  * Scripts.rxdata (a special version that just loads the individual script files).
* A few files in the main project folder (two of the Game.xxx files, and the RGSS dll file).
* Temporary files.
