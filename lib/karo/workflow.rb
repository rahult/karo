require 'karo/common'
require 'thor'
require 'grit'

module Karo

	class Workflow < Thor

    include Karo::Common

    desc "feature", "create a feature branch for a given name"
    def feature(name)
      branch_name = "feature/#{name}"

      if current_branch.eql?(branch_name)
        say "You are already on #{branch_name} this feature branch", :red
      elsif branch_exists? branch_name
        say "Feature branch #{branch_name} already exists! so checking it out", :red
        checkout_branch branch_name
      else
        create_and_checkout_branch branch_name
      end
    end

    desc "bugfix", "create a bug fix branch for a given name"
    def bugfix(name)
      branch_name = "bugfix/#{name}"

      if current_branch.eql?(branch_name)
        say "You are already on #{branch_name} this bug fix branch", :red
      elsif branch_exists? branch_name
        say "Bug fix branch #{branch_name} already exists! so checking it out", :red
        checkout_branch branch_name
      else
        create_and_checkout_branch branch_name
      end
    end

	end

end
