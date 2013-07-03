require 'karo/version'
require 'karo/config'
require 'karo/assets'
require 'karo/cache'
require 'karo/db'
require 'thor'
require 'ap'

module Karo

  class CLI < Thor

    include Thor::Actions

    class_option :config_file, type: :string, default: Config.default_file_name,
                  aliases: "-c", desc: "name of the file containing server configuration"
    class_option :environment, aliases: "-e", desc: "server environment", default: "production"

    desc "log", "displays server log for a given environment"
    def log(name="")
      configuration = Config.load_configuration(options)

      path = File.join(configuration["path"], "shared/log/#{options["environment"]}.log")
      ssh  = "ssh #{configuration["user"]}@#{configuration["host"]}"

      if name.eql?("")
        cmd = "tail -f #{path}"
      else
        cmd = "tail #{path} | grep -A 10 -B 10 #{name}"
      end

      system "#{ssh} '#{cmd}'"
    end

    desc "cache [search, remove]", "find or clears a specific or all cache from shared/cache directory on the server"
    subcommand "cache", Cache

    desc "assets [pull, push]", "syncs dragonfly assets between server shared/system/dragonfly/<environment> directory and local system/dragonfly/development directory"
    subcommand "assets", Assets

    desc "db [pull, push]", "syncs MySQL database between server and localhost"
    subcommand "db", Db

    desc "config", "displays server configuration stored in a config file"
    def config
      configuration = Config.load_configuration(options)

      ap configuration if configuration
    end

    def self.source_root
      File.dirname(__FILE__)
    end

    desc "generate", "generate a sample configuration file to be used by karo [default is .karo.yml]"
    def generate
      config_file = File.expand_path(options[:config_file])
      copy_file 'templates/karo.yml', config_file
    end

    desc "command [COMMAND]", "run any command within a given server environment"
    method_option :tty, aliases: "-t", desc: "force pseudo-tty allocation",
                  type: :boolean, default: true
    long_desc <<-LONGDESC
    `karo command [command]` or `karo cmd [command]`

    will run the [COMMAND] passed on the server.

    You can optionally pass --no-tty to disable ssh force pseudo-tty allocation

    e.g. Display list of files on the staging server

    > $ karo command ls -e staging --no-tty

    CHANGELOG.md Gemfile.lock README.md

    e.g. Run top command on the production server

    > $ karo command top

    > top - 17:14:06 up 219 days, 11:30,  1 user,  load average: 0.28, 0.49, 0.47

    You can also store custom commands for a given environment in the configuration file

    e.g. .karo.yml

    production:

    --host: example.com

    --user: deploy

    --path: /data/app_name

    --commands:

    ----memory: watch vmstat -sSM

    ----top_5_memory: ps aux | sort -nk +4 | tail

    > $ karo cmd memory

    > Every 2.0s: vmstat -sSM Tue Jul  2 17:18:16 2013

    > 35840140  total memory

    > 35308456  used memory

    > 25224800  active memory
    LONGDESC
    def command(cmd)
      configuration = Config.load_configuration(options)

      ssh  = "ssh #{configuration["user"]}@#{configuration["host"]}"

      # Forces pseudo-tty allocation
      ssh << " -t" if options[:tty]

      if configuration["commands"] && configuration["commands"][cmd]
        cmd = configuration["commands"][cmd]
      end

      system "#{ssh} '#{cmd}'"
    end
    map cmd: :command

    desc "on [COMMAND]", "run any command within a given server environment"
    method_option :tty, aliases: "-t", desc: "force pseudo-tty allocation",
                  type: :boolean, default: true
    def on(cmd)
      say "Deprecated and will be removed in version 2.0", :yellow
      say "Please use 'command' instead", :yellow
      invoke :command
    end

    desc "top", "run top command on a given server environment"
    def top
      invoke :command, ["top"]
    end

    desc "ssh", "open ssh console for a given server environment"
    def ssh
      configuration = Config.load_configuration(options)

      path = File.join(configuration["path"], "current")
      cmd  = "cd #{path}; export RAILS_ENV=#{options[:environment]}; \
              export RACK_ENV=#{options[:environment]}; $SHELL"

      invoke :command, [cmd]
    end

    desc "console", "open rails console for a given server environment"
    def console
      configuration = Config.load_configuration(options)

      path = File.join(configuration["path"], "current")
      cmd  = "cd #{path} && bundle exec rails console #{options[:environment]}"

      invoke :command, [cmd]
    end

    desc "version", "displays karo's current version"
    def version
      say Karo::VERSION
    end

  end

end
