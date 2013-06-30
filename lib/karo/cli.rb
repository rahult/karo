require 'karo/version'
require 'karo/config'
require 'karo/cache'
require 'thor'
require 'ap'

module Karo

	class CLI < Thor

	  class_option :config_file, type: :string, default: Config.default_file_name,
	  						  aliases: "-c", desc: "name of the file containing server configuration"
	  class_option :environment, aliases: "-e", desc: "server environment", default: "production"

	  desc "log", "displays server log for a given environment"
	  def log
	    configuration = Config.load_configuration(options)

	    path = File.join(configuration["path"], "shared/log/#{options["environment"]}.log")
	    ssh  = "ssh deploy@#{configuration["host"]}"
	    cmd  = "tail -f #{path}"

	    system "#{ssh} '#{cmd}'"
	  end

    desc "cache [find clear]", "find or clears a specific or all cache from shared/cache directory on the server"
    subcommand "cache", Cache

	  desc "config", "displays server configuration stored in a config file"
	  def config
	    configuration = Config.load_configuration(options)

	    ap configuration if configuration
	  end

	  desc "version", "displays karo's current version"
	  def version
	  	say Karo::VERSION
	  end

	end

end
