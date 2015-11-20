# Changelog

## v2.5.2

### Features

- Added option to pass environment as `env: production` setting within .karo.yml

## v2.5.1

### Features

- Disabled rugged

## v2.5.0

### Features

- Switched to [rugged](https://github.com/libgit2/rugged) for git manipulation
- Removed awesome print as a dependency

## v2.4.0

### Bug Fixes

- Fixed all SSH commands to load server environment before performing a task

## v2.3.9

### Features

- Updated to thor (0.19.1) and awesome_print (1.2.0)
- Enabled compression before migrating data from server to localhost

## v2.3.8

### Features

- Added option to store custom assets path and doing dry-runs

### Features

- Added support for custom assets path
- Added support doing a dry-run on any command with --dryrun or -d option

## v2.3.7

### Features

- Added support for custom assets path
- Added support doing a dry-run on any command with --dryrun or -d option

## v2.3.7

### Features

- Added support for pulling postgres databases

## v2.3.6

### Bug Fixes

- Now mysql server db server config loads proper hostname in sync query instead of just using `localhost` by default

## v2.3.5

### Bug Fixes

- Removed hard coded `localhost` host dependency from db server config

## v2.3.4

### Features

- Added command 'vim' to open a file/folder on a given server using VIM

### Bug Fixes

- Removed hard coded `deploy` user dependency from assets server config

## v2.3.3

### Bug Fixes

- Removed hard coded `deploy` user dependency from assets server config

## v2.3.2

### Bug Fixes

- Removed hard coded `deploy` user dependency from  db server config [https://github.com/rahult/karo/pull/5](https://github.com/rahult/karo/pull/5)

## v2.3.1

### Features

- Added semantic dependency values for thor, grit and awesome_print

## v2.3.0

### Features

- Updated readme
- Removed fixed rake version dependency

## v2.2.1

### Features

- Added a shortcut for `karo client deploy` -> `karo deploy`

## v2.2.0

### Features

- Added basic git workflow to create feature and bug fix branches

## v2.1.3

### Features

- Updated some comments in CLI

## v2.1.2

### Features

- Refactoring Db "pull" command

## v2.1.1

### Features

- Refactoring CLI "server" and "client" commands

## v2.1.0

### Features

- Added command 'rake' to run rake tasks for a rails app on a given server environment
- Added options to pass extra command line parameters to 'server' command
- Added options to pass extra command line parameters to 'client' command
- Added options to pass extra command line parameters to 'log' command
- Added options to pass extra command line parameters to 'top' command

## v2.0.0

### Features

- Added command 'server' to execute commands remotely
- Added command 'client' to execute commands locally
- Removed command 'command', supceded by 'server'

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
