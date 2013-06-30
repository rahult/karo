require 'yaml'
require 'thor'

module Karo

	class NoConfigFileFoundError < StandardError; end

	class Config

		def self.default_file_name
			".karo.yml"
		end

	  def self.load_configuration(options)
	  	begin
        config_file = File.expand_path(options[:config_file])
	  		configuration = read_configuration(config_file)[options[:environment]]

		  	if configuration.nil? || configuration.empty?
		  		raise Thor::Error, "Please pass a valid configuration for an environment '#{options[:environment]}' within this file '#{config_file}'"
		  	else
		  		configuration
		  	end
		  rescue Karo::NoConfigFileFoundError
		  	raise Thor::Error, "Please make sure that this configuration file exists? '#{config_file}'"
		  end
	  end

	  private

	  def self.read_configuration(file_name)
	    if File.exist?(file_name)
	      YAML.load_file(file_name)
	    else
	      raise NoConfigFileFoundError
	    end
	  end

	end

end
