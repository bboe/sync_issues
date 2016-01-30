require_relative 'error'

module SyncIssues
  # Synchronizer is responsible for the actual synchronization.
  class Issue
    attr_reader :assignee, :content, :title

    def initialize(content, title:, assignee: nil)
      @assignee = verify_string 'assignee', assignee
      @content = content
      @title = verify_string 'title', title, allow_nil: false
    end

    private

    def verify_string(field, value, allow_nil: true)
      if value.nil?
        raise IssueError, "'#{field}' must be provided" unless allow_nil
      elsif !value.is_a?(String)
        raise IssueError, "'#{field}' must be a string"
      else
        value.strip!
        raise IssueError, "'#{field}' must not be blank" if value == ''
      end
      value
    end
  end
end
