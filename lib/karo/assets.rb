require 'karo/common'
require 'thor'

module Karo

	class Assets < Thor

    include Karo::Common

	  desc "pull", "syncs assets from server shared/system/dragonfly/<environment> directory into local system/dragonfly/development directory"
    long_desc <<-LONGDESC
    You can also change assets server and local path for a given environment in the configuration file

    e.g. .karo.yml

    production:

    --assets:

    ----server: /data/app/shared/assets

    ----local: shared/assets
    LONGDESC
	  def pull
	    configuration = Config.load_configuration(options)

      assets   = configuration["assets"]
      assets ||= {}

      path_local   = assets["local"]
      path_local ||= "public/system/dragonfly/development"
      path_local   = File.expand_path(path_local)

      empty_directory path_local if !File.exists?(path_local) && !options[:dryrun]

      path_server   = assets["server"]
      path_server ||= File.join(configuration["path"], "shared/system/dragonfly/#{options[:environment]}")

	    host = "#{configuration["user"]}@#{configuration["host"]}"
	    command  = "rsync -az --progress #{host}:#{path_server}/ #{path_local}/"

      run_it command, options[:verbose]

      say "Assets sync complete", :green
	  end

    desc "push", "syncs assets from system/dragonfly/development directory into local server shared/system/dragonfly/<environment> directory"
    long_desc <<-LONGDESC
    You can also change assets server and local path for a given environment in the configuration file

    e.g. .karo.yml

    production:

    --assets:

    ----server: /data/app/shared/assets

    ----local: shared/assets
    LONGDESC
	  def push
      configuration = Config.load_configuration(options)

      assets   = configuration["assets"]
      assets ||= {}

      path_local   = assets["local"]
      path_local ||= "public/system/dragonfly/development"
      path_local   = File.expand_path(path_local)

      unless File.exists?(path_local)
        raise Thor::Error, "Please make sure that this local path exists? '#{path_local}'"
      end

      host = "#{configuration["user"]}@#{configuration["host"]}"

      path_server   = assets["server"]
      path_server ||= File.join(configuration["path"], "shared/system/dragonfly/#{options[:environment]}")

      command_1  = "ssh #{host} 'mkdir -p #{path_server}'"
      command_2  = "rsync -az --progress #{path_local}/ #{host}:#{path_server}/"

      if yes?("Are you sure?", :yellow)
        run_it command_1, options[:verbose]
        run_it command_2, options[:verbose]
        say "Assets sync complete", :green
      else
        say "Assets sync cancelled", :yellow
      end
	  end

	end

end
