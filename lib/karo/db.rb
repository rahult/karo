require 'karo/config'
require 'thor'
require 'yaml'
require 'erb'
require 'ap'

module Karo

	class Db < Thor

    include Thor::Actions

    class_option :config_file, type: :string, default: Config.default_file_name,
                  aliases: "-c", desc: "name of the file containing server configuration"
    class_option :environment, aliases: "-e", desc: "server environment", default: "production"

    method_option :migrate, aliases: "-m", desc: "run migrations after sync", default: true
	  desc "pull", "syncs MySQL database from server to localhost"
	  def pull
	    configuration = Config.load_configuration(options)

      local_db_config_file  = File.expand_path("config/database.yml")
      unless File.exists?(local_db_config_file)
        raise Thor::Error, "Please make sure that this file exists locally? '#{local_db_config_file}'"
      end

      local_db_config = YAML.load(File.read('config/database.yml'))

      if local_db_config["development"].nil? || local_db_config["development"].empty?
        raise Thor::Error, "Please make sure MySQL development configuration exists within this file? '#{local_db_config_file}'"
      end

      local_db_config = local_db_config["development"]

      say "Loading local database configuration", :green

      server_db_config_file = File.join(configuration["path"], "shared/config/database.yml")

	    host = "deploy@#{configuration["host"]}"
	    cmd  = "ssh #{host} 'cat #{server_db_config_file}'"

      server_db_config_output = `#{cmd}`
      yaml_without_any_ruby = ERB.new(server_db_config_output).result
      server_db_config = YAML.load(yaml_without_any_ruby)

      if server_db_config[options[:environment]].nil? || server_db_config[options[:environment]].empty?
        raise Thor::Error, "Please make sure MySQL development configuration exists within this file? '#{server_db_config_file}'"
      end

      server_db_config = server_db_config[options[:environment]]

      say "Loading #{options[:environment]} server database configuration", :green

      # Drop local database and re-create
      system "mysql -v -h #{local_db_config["host"]} -u#{local_db_config["username"]} -p#{local_db_config["password"]} -e 'DROP DATABASE IF EXISTS `#{local_db_config["database"]}`; CREATE DATABASE IF NOT EXISTS `#{local_db_config["database"]}`;'"

      ssh  = "ssh #{configuration["user"]}@#{configuration["host"]}"

      system "#{ssh} \"mysqldump --opt -C -u#{server_db_config["username"]} -p#{server_db_config["password"]} #{server_db_config["database"]}\" | mysql -v -h #{local_db_config["host"]} -C -u#{local_db_config["username"]} -p#{local_db_config["password"]} #{local_db_config["database"]}"

      if options[:migrate]
        say "Running rake db:migrations", :green
        system "bundle exec rake db:migrate"
      end

      say "Database sync complete", :green
	  end

    desc "push", "syncs MySQL database from localhost to server"
	  def push
      say "Pending Implementation...", :yellow
	  end

    desc "console", "open rails dbconsole for a given server environment"
    def console
      configuration = Config.load_configuration(options)

      path = File.join(configuration["path"], "current")
      ssh  = "ssh #{configuration["user"]}@#{configuration["host"]} -t"
      cmd  = "cd #{path} && bundle exec rails dbconsole #{options[:environment]} -p"
      system "#{ssh} '#{cmd}'"
    end

	end

end
