require 'karo/common'
require 'erb'

module Karo

	class Db < Thor

    include Karo::Common

    method_option :migrate, aliases: "-m", desc: "run migrations after sync", default: true
	  desc "pull", "syncs MySQL database from server to localhost"
	  def pull
	    @configuration = Config.load_configuration(options)

      local_db_config  = load_local_db_config
      server_db_config = load_server_db_config

      drop_and_create_local_database(local_db_config)

      sync_server_to_local_database(server_db_config, local_db_config)

      if options[:migrate]
        say "Running rake db:migrations", :green
        run_it "bundle exec rake db:migrate", options[:verbose]
      end

      say "Database sync complete", :green
	  end

    desc "push", "syncs MySQL database from localhost to server"
	  def push
      say "Pending Implementation...", :yellow
	  end

    desc "console", "open rails dbconsole for a given server environment"
    method_option :tty, aliases: "-t", desc: "force pseudo-tty allocation",
                  type: :boolean, default: true
    def console
      configuration = Config.load_configuration(options)

      path = File.join(configuration["path"], "current")
      ssh  = "ssh #{configuration["user"]}@#{configuration["host"]}"
      ssh << " -t" if options[:tty]

      command  = "cd #{path} && bundle exec rails dbconsole #{options[:environment]} -p"

      run_it "#{ssh} '#{command}'", options[:verbose]
    end

    private

    def load_local_db_config
      local_db_config_file  = File.expand_path("config/database.yml")

      unless File.exists?(local_db_config_file)
        raise Thor::Error, "Please make sure that this file exists locally? '#{local_db_config_file}'"
      end

      local_db_config = YAML.load(File.read('config/database.yml'))

      if local_db_config["development"].nil? || local_db_config["development"].empty?
        raise Thor::Error, "Please make sure MySQL development configuration exists within this file? '#{local_db_config_file}'"
      end

      say "Loading local database configuration", :green

      local_db_config["development"]
    end

    def load_server_db_config
      server_db_config_file = File.join(@configuration["path"], "shared/config/database.yml")

      host = "#{@configuration["user"]}@#{@configuration["host"]}"
      cmd  = "ssh #{host} 'cat #{server_db_config_file}'"

      server_db_config_output = `#{cmd}`
      yaml_without_any_ruby = ERB.new(server_db_config_output).result
      server_db_config = YAML.load(yaml_without_any_ruby)

      if server_db_config[options[:environment]].nil? || server_db_config[options[:environment]].empty?
        raise Thor::Error, "Please make sure MySQL development configuration exists within this file? '#{server_db_config_file}'"
      end

      say "Loading #{options[:environment]} server database configuration", :green

      server_db_config[options[:environment]]
    end

    def drop_and_create_local_database(local_db_config)
      command = "mysql -v -h #{local_db_config["host"]} -u#{local_db_config["username"]} -p#{local_db_config["password"]} -e 'DROP DATABASE IF EXISTS `#{local_db_config["database"]}`; CREATE DATABASE IF NOT EXISTS `#{local_db_config["database"]}`;'"

      run_it command, options[:verbose]
    end

    def sync_server_to_local_database(server_db_config, local_db_config)
      ssh = "ssh #{@configuration["user"]}@#{@configuration["host"]}"

      command = "#{ssh} \"mysqldump --opt -C -h #{server_db_config["host"]} -u#{server_db_config["username"]} -p#{server_db_config["password"]} -h#{server_db_config["host"]} #{server_db_config["database"]}\" | mysql -v -h #{local_db_config["host"]} -C -u#{local_db_config["username"]} -p#{local_db_config["password"]} #{local_db_config["database"]}"

      run_it command, options[:verbose]
    end

	end

end
