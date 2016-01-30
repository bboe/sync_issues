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
        @issue = Issue.new content, **hash_keys_to_symbols(metadata)
      end
    rescue ArgumentError => exc
      raise ParseError, exc.message
    rescue Psych::SyntaxError
      raise ParseError, 'invalid frontmatter'
    end

    private

    def hash_keys_to_symbols(hash)
      hash.each_with_object({}) do |(key, value), tmp_hash|
        tmp_hash[key.to_sym] = value
      end
    end
  end
end
