require_relative 'error'

module SyncIssues
  # Synchronizer is responsible for the actual synchronization.
  class Issue
    attr_reader :assignee, :content, :title

    def initialize(content, metadata)
      unless metadata.include?('title')
        raise Error, 'title missing in frontmatter'
      end
      @assignee = verify_string 'assignee', metadata['assignee']
      @content = content
      @title = verify_string 'title', metadata['title'], allow_nil: false
    end

    private

    def verify_string(field, value, allow_nil: true)
      if value.nil?
        raise Error, "'#{field}' must be provided" unless allow_nil
      elsif !value.is_a?(String)
        raise Error, "'#{field}' can only be a string"
      end
      value
    end
  end
end
