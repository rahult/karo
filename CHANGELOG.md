# Changelog

## v1.5.0

### Bug Fixes

- Fixed ssh command to export RAILS_ENV and RACK_ENV before starting the shell
- Updated description for assets command to specify dragonfly

## v1.4.0

### Features

- Added command 'command' to supercede 'on' command and deprecated 'on'
- Added options to store custom commands for an environment within .karo.yml file

## v1.3.0

### Features

- Added command to run top on a server
- Added command to run any command on a server

## v1.2.1

### Bug Fixes

- Fixed a bug causing db pull to fail if no database exist

## v1.2.0

### Features

- Added a .karo.yml template generator

### Bug Fixes

- Fixed a bug causing conflict passing global option to sub commands

## v1.1.0

### Features

- Added command to open ssh shell
- Added command to open rails console
- Added command to open rails dbconsole

## v1.0.0

### Features

- Added basic commands to sync db, assets from remote rails servers
- Added basic commands to show log, clear cache from remote rails servers
