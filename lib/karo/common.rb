require 'karo/config'
require 'thor'

module Karo

  module Common Thor

    include Thor::Actions

    def make_command(configuration, namespace, command, extras)
      commands = configuration["commands"]

      if commands && commands[namespace] && commands[namespace][command]
        command = commands[namespace][command]
        command.sub! "{{user}}", configuration["user"]
        command.sub! "{{host}}", configuration["host"]
        command.sub! "{{path}}", configuration["path"]
      end

      extras = extras.flatten(1).uniq.join(" ").strip

      "#{command} #{extras}"
    end

    def run_it(cmd, verbose=false)
      say cmd, :green if verbose
      system cmd unless options[:dryrun]
    end

    def git_repo
      Rugged::Repository.new(".")
    end

    def branch_exists?(name)
      git_repo.branches.find { |b| b.name.start_with?(name) }
    end

    def create_branch(name)
      run_it "git branch #{name}", options[:verbose]
    end

    def checkout_branch(name)
      run_it "git checkout #{name}", options[:verbose]
    end

    def current_branch
      git_repo.head.name
    end

    def create_and_checkout_branch(name)
      create_branch name
      checkout_branch name
    end

  end

end
