require_relative 'command'
require_relative 'synchronizer'

# SyncIssues
module SyncIssues
  class << self
    def command
      @command ||= SyncIssues::Command.new
    end

    def synchronizer(directory, repositories)
      SyncIssues::Synchronizer.new(directory, repositories)
    end
  end
end
