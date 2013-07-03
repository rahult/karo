require 'karo/config'
require 'thor'

module Karo

	class Assets < Thor

    include Thor::Actions

    class_option :config_file, type: :string, default: Config.default_file_name,
                  aliases: "-c", desc: "name of the file containing server configuration"
    class_option :environment, aliases: "-e", desc: "server environment", default: "production"
    class_option :verbose, type: :boolean, lazy_default: true, aliases: "-v", desc: "verbose"

	  desc "pull", "syncs assets from server shared/system/dragonfly/<environment> directory into local system/dragonfly/development directory"
	  def pull
	    configuration = Config.load_configuration(options)

      path_local  = File.expand_path("public/system/dragonfly/development")
      empty_directory path_local unless File.exists?(path_local)

      path_server = File.join(configuration["path"], "shared/system/dragonfly/#{options[:environment]}")

	    host = "deploy@#{configuration["host"]}"
	    cmd  = "rsync -az --progress #{host}:#{path_server}/ #{path_local}/"

      say cmd, :green if options[:verbose]

      system cmd

      say "Assets sync complete", :green
	  end

    desc "push", "syncs assets from system/dragonfly/development directory into local server shared/system/dragonfly/<environment> directory"
	  def push
      configuration = Config.load_configuration(options)

      path_local  = File.expand_path("public/system/dragonfly/development")
      unless File.exists?(path_local)
        raise Thor::Error, "Please make sure that this local path exists? '#{path_local}'"
      end

      host = "deploy@#{configuration["host"]}"

      path_server = File.join(configuration["path"], "shared/system/dragonfly/#{options[:environment]}")

      cmd_1  = "ssh #{host} 'mkdir -p #{path_server}'"
      cmd_2  = "rsync -az --progress #{path_local}/ #{host}:#{path_server}/"

      if options[:verbose]
        say cmd_1, :green
        say cmd_2, :green
      end

      if yes?("Are you sure?", :yellow)
        system "#{cmd_1}"
        system "#{cmd_2}"
        say "Assets sync complete", :green
      else
        say "Assets sync cancelled", :yellow
      end
	  end

	end

end
