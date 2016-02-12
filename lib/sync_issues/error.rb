module SyncIssues
  class Error < StandardError
  end

  class IssueError < Error
  end

  class ParseError < Error
  end

  class TokenError < Error
  end
end
