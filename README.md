# Pokémon Essentials

Based on Essentials v18.

You can build your fangame on top of a fork of this repository. Doing so will let you update your fangame with improvements made to this repo as soon as they are made.

## Usage

1. Fork this repo.
2. Get a copy of Essentials v18 (a download link cannot be provided here).
3. Clone your forked repo into the Essentials v18 folder, replacing the existing files with the ones from the repo.

From here, you can edit this project to turn it into your fangame/develop mods. When this repo is updated, you can make a pull request to update your fork and get the updated into your fangame/modding environment.

## Scripts

The scripts no longer live in the Scripts.rxdata file. They have been extracted into separate files and placed in the Data/Scripts/ folder (and subfolders within).

The scripts are loaded into the game alphabetically, starting from the top folder (Data/Scripts/) and going depth-first. All scripts in a given folder are loaded, and then each subfolder is checked in turn (again in alphabetical order) for files/folders to load/check.

### Reintegrating scripts for an encrypted release

This repo contains script_dumper.rb (in the main folder) which can be run to integrate the individual script files back into Scripts.rxdata, and to extract them. At the bottom of script_dumper.rb are two lines, one for each action.

This will not be described in detail, as the intention is to replace it with something more user-friendly.

## Files not in the repo

The .gitignore file lists the files that will not be included in this repo. These are:

* The Audio/ and Graphics/ folders and everything in them.
* Everything in the Data/ folder, except for:
  * The Data/Scripts/ folder and everything in there.
  * Scripts.rxdata (a special version that just loads the individual script files).
* A few files in the main project folder (the three Game.xxx files, and the RGSS dll file).
* Temporary files.