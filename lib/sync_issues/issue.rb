require_relative 'error'

module SyncIssues
  # Issue represents an issue to be added or updated.
  #
  # new_title is only used when an issue should be renamed. Issues with
  # new_title set will never be created
  class Issue
    attr_reader :assignee, :content, :new_title, :title

    def initialize(content, title:, assignee: nil, new_title: nil)
      @assignee = verify_string 'assignee', assignee
      @content = content
      @title = verify_string 'title', title, allow_nil: false
      @new_title = verify_string 'new_title', new_title, allow_nil: true
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
