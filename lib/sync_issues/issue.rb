require_relative 'error'

module SyncIssues
  # Issue represents an issue to be added or updated.
  #
  # new_title is only used when an issue should be renamed. Issues with
  # new_title set will never be created
  class Issue
    attr_reader :assignee, :content, :labels, :new_title, :title

    def initialize(content, title:, assignee: nil, labels: nil, new_title: nil)
      @assignee = verify_string 'assignee', assignee
      @content = content
      @labels = verify_labels(labels)
      @new_title = verify_string 'new_title', new_title, allow_nil: true
      @title = verify_string 'title', title, allow_nil: false
    end

    private

    def verify_labels(labels)
      return nil if labels.nil?
      if labels.is_a?(String)
        [verify_string('labels', labels, allow_nil: false)]
      elsif !labels.is_a?(Array)
        raise IssueError, "'labels' must be an Array or a String"
      else
        labels.each_with_index.map do |label, i|
          verify_string("labels[#{i}]", label, allow_nil: false)
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
