require_relative 'command'
require_relative 'github'
require_relative 'synchronizer'

# SyncIssues
module SyncIssues
  class << self
    def command
      @command ||= Command.new
    end

    def github
      @github ||= GitHub.new
    end

    def synchronizer(*args)
      Synchronizer.new(*args)
    end
  end
end
