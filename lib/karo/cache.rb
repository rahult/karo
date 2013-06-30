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

      system "#{ssh} '#{cmd}'"
	  end

	  desc "remove", "removes any matching cache files from the shared/cache directory"
	  def remove(name="")
      invoke :search

      configuration = Config.load_configuration(options)
      path = File.join(configuration["path"], "shared/cache")
      ssh  = "ssh #{configuration["user"]}@#{configuration["host"]}"
      cmd  = "find #{path} -type f -name \"*#{name}*\" -delete"

      if yes?("Are you sure?", :yellow)
        system "#{ssh} '#{cmd}'"
        say "Cache removed", :green
      else
        say "Cache not removed", :yellow
      end
	  end

	end

end
