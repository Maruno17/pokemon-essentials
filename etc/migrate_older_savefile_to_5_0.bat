echo POKEMON INFINITE FUSION 5.0 savefile utility
echo Moving the game's savefile to appdata folder
@echo off
chcp 65001
xcopy "C:\Users\%USERNAME%\Saved Games\Pokémon Infinite Fusion\Game.rxdata" "C:\Users\%USERNAME%\AppData\Roaming\infinitefusion\"
PAUSE