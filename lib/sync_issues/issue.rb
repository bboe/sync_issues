require_relative 'error'

module SyncIssues
  # Issue represents an issue to be added or updated.
  #
  # new_title is only used when an issue should be renamed. Issues with
  # new_title set will never be created
  class Issue
    attr_reader :assignees, :content, :labels, :new_title, :title

    def initialize(content, title:, assignees: nil, labels: nil, new_title: nil)
      @assignees = verify_array_or_string 'assignees', assignees
      @assignees.sort! unless @assignees.nil?
      @content = content
      @labels = verify_array_or_string 'labels', labels
      @new_title = verify_string 'new_title', new_title, allow_nil: true
      @title = verify_string 'title', title, allow_nil: false
    end

    private

    def verify_array_or_string(field, items)
      return nil if items.nil?
      if items.is_a?(String)
        [verify_string(field, items, allow_nil: false)]
      elsif !items.is_a?(Array)
        raise IssueError, "'#{field}' must be an Array or a String"
      else
        items.each_with_index.map do |item, i|
          verify_string("#{field}[#{i}]", item, allow_nil: false)
        end
      end
    end

    def verify_string(field, value, allow_nil: true)
      if value.nil?
        raise IssueError, "'#{field}' must be provided" unless allow_nil
      elsif !value.is_a?(String)
        raise IssueError, "'#{field}' must be a String"
      else
        value.strip!
        raise IssueError, "'#{field}' must not be blank" if value == ''
      end
      value
    end
  end
end
