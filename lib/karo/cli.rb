require 'karo/version'
require 'karo/config'
require 'karo/cli'
require 'thor'
require 'pry'
require 'ap'

module Karo

	class CLI < Thor
	  class_option :config_file, type: :string, default: Config.default_file_name,
	  						  aliases: "-c", desc: "The name of the file containing the server configuration"
	  class_option :environment, aliases: "-e", desc: "environment", default: "production"

	  desc "log", "displays server log for a given environment"
	  def log
	    configuration = load_configuration(options)
	    path = File.join(configuration["path"], "shared/log/#{options["environment"]}.log")
	    ssh  = "ssh deploy@#{configuration["host"]}"
	    cmd  = "#{ssh} \"tail -f #{path}\""

	    system cmd
	  end

	  desc "config", "displays server configuration stored in a config file"
	  def config
	    configuration = load_configuration(options)
	    ap configuration if configuration
	  end

	  desc "version", "displays karo's current version"
	  def version
	  	say Karo::VERSION
	  end

	  private

	  def load_configuration(options)
	  	begin
        config_file = File.expand_path(options[:config_file])
	  		configuration = Config.load_configuration(config_file)[options[:environment]]
		  	if configuration.nil? || configuration.empty?
		  		raise Thor::Error, "Please pass a valid configuration for an environment '#{options[:environment]}'"
		  	else
		  		configuration
		  	end
		  rescue Karo::NoConfigFileFoundError
		  	raise Thor::Error, "Please make sure if this configuration file exists? '#{config_file}'"
		  end
	  end

	end

end
