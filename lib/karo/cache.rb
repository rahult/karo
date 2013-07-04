require 'karo/config'
require 'thor'

module Karo

	class Cache < Thor

	  desc "search", "searches for any matching cache files from the shared/cache directory"
	  def search(name="")
	    configuration = Config.load_configuration(options)
	    path = File.join(configuration["path"], "shared/cache")
      ssh  = "ssh #{configuration["user"]}@#{configuration["host"]}"
      cmd  = "find #{path} -type f -name \"*#{name}*\""

      to_run = "#{ssh} '#{cmd}'"

      say to_run, :green if options[:verbose]
      system to_run
	  end

	  desc "remove", "removes any matching cache files from the shared/cache directory"
	  def remove(name="")
      invoke :search

      configuration = Config.load_configuration(options)
      path = File.join(configuration["path"], "shared/cache")
      ssh  = "ssh #{configuration["user"]}@#{configuration["host"]}"
      cmd  = "find #{path} -type f -name \"*#{name}*\" -delete"

      to_run = "#{ssh} '#{cmd}'"

      if yes?("Are you sure?", :yellow)
        say to_run, :green if options[:verbose]
        system to_run
        say "Cache removed", :green
      else
        say "Cache not removed", :yellow
      end
	  end

	end

end
