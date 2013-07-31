require_relative 'extensions/hash'
require 'yaml'
require 'thor'

module Karo

  class Config

    def self.default_file_name
      ".karo.yml"
    end

    def self.load_configuration(options)
      configuration = lookup_configuration(Dir.getwd, options[:config_file])
      configuration = configuration[options[:environment]]

      if configuration.nil? || configuration.empty?
        puts "Please pass a valid configuration for an environment '#{options[:environment]}' within this file '#{File.expand_path(options[:config_file])}'"
        raise Thor::Error, "You can use 'karo generate' to generate a skeleton .karo.yml file"
      else
        configuration
      end
    end

    private

    def self.lookup_configuration(dir, config_file, configuration={})
      return configuration if dir.empty?

      config_file_path = File.join(dir, config_file)
      config = read_configuration(config_file_path)

      lookup_configuration(pop_dir(dir), config_file, config.deep_merge(configuration))
    end

    def self.pop_dir(dir)
      dirs = dir.split("/")
      dirs.pop
      dirs.join("/")
    end

    def self.read_configuration(file_name)
      if File.exist?(file_name)
        YAML.load_file(file_name)
      else
        {}
      end
    end

  end

end
