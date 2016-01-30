module SyncIssues
  class Error < StandardError
  end

  class IssueError < Error
  end

  class ParseError < Error
  end
end
