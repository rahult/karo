require 'karo/workflow'
require 'karo/version'
require 'karo/common'
require 'karo/assets'
require 'karo/cache'
require 'karo/db'
require 'json'

module Karo

  class CLI < Thor

    include Karo::Common

    # FIXME: Duplicated in Karo::Common but is needed for the generate method
    include Thor::Actions

    class_option :config_file, type: :string, default: Config.default_file_name,
                  aliases: "-c", desc: "name of the file containing server configuration"
    class_option :environment, aliases: "-e", desc: "server environment", default: "production"
    class_option :verbose, type: :boolean, lazy_default: true, aliases: "-v", desc: "verbose"
    class_option :dryrun,  type: :boolean, lazy_default: true, aliases: "-d", desc: "dry-run"

    desc "cache [search, remove]", "find or clears a specific or all cache from shared/cache directory on the server"
    subcommand "cache", Cache

    desc "assets [pull, push]", "syncs dragonfly assets between server shared/system/dragonfly/<environment> directory and local system/dragonfly/development directory"
    subcommand "assets", Assets

    desc "db [pull, push, console]", "syncs MySQL database between server and localhost"
    subcommand "db", Db

    desc "workflow [feature, bugfix]", "basic git workflow to create feature and bugfix branches"
    subcommand "workflow", Workflow

    desc "config", "displays server configuration stored in a config file"
    def config
      configuration = Config.load_configuration(options)

      puts JSON.pretty_generate(configuration) if configuration
    end

    def self.source_root
      File.dirname(__FILE__)
    end

    desc "generate", "generate a sample configuration file to be used by karo [default is .karo.yml]"
    def generate
      config_file = File.expand_path(options[:config_file])
      copy_file 'templates/karo.yml', config_file
    end

    desc "client [COMMAND]", "run any command within a given client environment"
    long_desc <<-LONGDESC
    `karo client [command]` or `karo clt [command]` will run the [COMMAND] cliently.

    e.g. Display list of files on the client machine

    > $ karo client ls

    CHANGELOG.md Gemfile.lock README.md

    You can also store custom commands for a given environment in the configuration file

    e.g. .karo.yml

    production:

    --commands:

    ----client:

    ------deploy: ey deploy -e production -r master

    > $ karo clt deploy

    > Loading application data from Engine Yard Cloud...

    > Beginning deploy...
    LONGDESC
    def client(cmd, *extras)
      configuration = Config.load_configuration(options)
      command = make_command configuration, "client", cmd, extras
      run_it command, options[:verbose]
    end
    map clt:   :client
    map local: :client

    desc "deploy", "(shortcut for > karo client deploy)"
    def deploy(*extras)
      invoke :client, ["deploy", extras]
    end

    desc "server [COMMAND]", "run any command within a given server environment"
    method_option :tty, aliases: "-t", desc: "force pseudo-tty allocation",
                  type: :boolean, default: true
    long_desc <<-LONGDESC
    `karo server [command]` or `karo srv [command]`

    will run the [COMMAND] passed on the server.

    You can optionally pass --no-tty to disable ssh force pseudo-tty allocation

    e.g. Display list of files on the staging server

    > $ karo server ls -e staging --no-tty

    CHANGELOG.md Gemfile.lock README.md

    e.g. Run top command on the production server

    > $ karo server top

    > top - 17:14:06 up 219 days, 11:30,  1 user,  load average: 0.28, 0.49, 0.47

    You can also store custom commands for a given environment in the configuration file

    e.g. .karo.yml

    production:

    --commands:

    ----server:

    ------memory: watch vmstat -sSM

    > $ karo srv memory

    > Every 2.0s: vmstat -sSM Tue Jul  2 17:18:16 2013

    > 35840140  total memory

    > 35308456  used memory
    LONGDESC
    def server(cmd, *extras)
      configuration = Config.load_configuration(options)

      ssh  = "ssh #{configuration["user"]}@#{configuration["host"]}"
      ssh << " -t" if options[:tty]

      command = make_command configuration, "server", cmd, extras
      run_it "#{ssh} '#{command}'", options[:verbose]
    end
    map srv:    :server
    map remote: :server

    desc "top", "run top command on a given server environment"
    def top(*extras)
      invoke :server, ["top", extras]
    end

    desc "ssh", "open ssh console for a given server environment"
    def ssh
      configuration = Config.load_configuration(options)

      path = File.join(configuration["path"], "current")
      cmd  = "cd #{path}; $SHELL --login"

      invoke :server, [cmd]
    end

    desc "console", "open rails console for a given server environment"
    def console
      configuration = Config.load_configuration(options)

      path = File.join(configuration["path"], "current")
      cmd  = "cd #{path} && $SHELL --login -c \"bundle exec rails console\""

      invoke :server, [cmd]
    end

    desc "rake", "run rake commands for a rails app on a given server environment"
    def rake(command, *extras)
      configuration = Config.load_configuration(options)

      path = File.join(configuration["path"], "current")
      cmd  = "cd #{path} && $SHELL --login -c \"bundle exec rake #{command}\""

      invoke :server, [cmd, extras]
    end

    desc "vim", "open a given file or folder on the server using VIM"
    def vim(command="", *extras)
      configuration = Config.load_configuration(options)

      path = File.join(configuration["path"], "current", command)
      cmd  = "vim scp://#{configuration["user"]}@#{configuration["host"]}/#{path}"

      invoke :client, [cmd, extras]
    end

    desc "log", "displays server log for a given environment"
    class_option :continous, type: :boolean, lazy_default: true, aliases: "-f", desc: "The -f option causes tail to not stop when end of file is reached, but rather to wait for additional data to be appended to the input."
    def log(*extras)
      configuration = Config.load_configuration(options)

      path = File.join(configuration["path"], "shared/log/#{options["environment"]}.log")

      cmd = "tail"
      cmd << " -f" if options[:continous]
      cmd << " #{path}"

      invoke :server, [cmd, extras]
    end

    desc "version", "displays karo's current version"
    def version
      say Karo::VERSION
    end

  end

end
