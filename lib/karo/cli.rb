require 'karo/version'
require 'karo/config'
require 'karo/assets'
require 'karo/cache'
require 'karo/db'
require 'thor'
require 'ap'

module Karo

	class CLI < Thor

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

    desc "assets [pull, push]", "syncs assets between server shared/system/dragonfly/<environment> directory and local system/dragonfly/development directory"
    subcommand "assets", Assets

    desc "db [pull, push]", "syncs MySQL database between server and localhost"
    subcommand "db", DB

	  desc "config", "displays server configuration stored in a config file"
	  def config
	    configuration = Config.load_configuration(options)

	    ap configuration if configuration
	  end

	  desc "ssh", "open ssh console for a given server environment"
	  def ssh
	    configuration = Config.load_configuration(options)

	    path = File.join(configuration["path"], "current")
	    ssh  = "ssh -t #{configuration["user"]}@#{configuration["host"]}"
	    cmd  = "cd #{path} && $SHELL"
	    system "#{ssh} '#{cmd}'"
	  end

	  desc "console", "open rails console for a given server environment"
	  def console
	    configuration = Config.load_configuration(options)

	    path = File.join(configuration["path"], "current")
	    ssh  = "ssh #{configuration["user"]}@#{configuration["host"]} -t"
	    cmd  = "cd #{path} && bundle exec rails console #{options[:environment]}"
	    system "#{ssh} '#{cmd}'"
	  end

	  desc "version", "displays karo's current version"
	  def version
	  	say Karo::VERSION
	  end

	end

end
