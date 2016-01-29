require_relative 'error'
require_relative 'issue'
require 'safe_yaml/load'

module SyncIssues
  # Synchronizer is responsible for the actual synchronization.
  class Parser
    attr_reader :issue

    def initialize(data)
      @issue = nil
      parse(data)
    end

    def parse(data)
      unless data =~ /\A(---\s*\n.*?\n?)^((---|\.\.\.)\s*$\n?)/m
        raise ParseError, 'missing frontmatter'
      end

      if (content = $POSTMATCH).empty?
        raise ParseError, 'empty markdown content'
      elsif (metadata = SafeYAML.load(Regexp.last_match(1))).nil?
        raise ParseError, 'empty frontmatter'
      else
        @issue = Issue.new content, metadata
      end
    rescue Psych::SyntaxError
      raise ParseError, 'invalid frontmatter'
    end
  end
end
