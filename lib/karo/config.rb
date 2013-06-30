require 'yaml'

module Karo

	class NoConfigFileFoundError < StandardError; end

	class Config

		def self.default_file_name
			".karo.yml"
		end

	  def self.load_configuration(file_name)
	    if File.exist?(file_name)
	      YAML.load_file(file_name)
	    else
	      raise NoConfigFileFoundError
	    end
	  end

	end

end
