require 'karo/config'
require 'thor'

module Karo

  module Common Thor

    include Thor::Actions

    def make_command(configuration, namespace, command, extras)
      commands = configuration["commands"]

      if commands && commands[namespace] && commands[namespace][command]
        command = commands[namespace][command]
      end

      extras = extras.flatten(1).uniq.join(" ").strip

      "#{command} #{extras}"
    end

    def run_it(cmd, verbose=false)
      say cmd, :green if verbose
      system cmd
    end

  end

end
