require_relative 'error'

module SyncIssues
  # Comparison represents differences between Issues (local and GitHub)
  class Comparison
    attr_reader :assignee, :changed, :content, :title

    def initialize(issue, github_issue, sync_assignee)
      @changed = []
      @assignee = github_issue.assignee && github_issue.assignee.login
      @content = github_issue.body
      @sync_assignee = sync_assignee
      @title = github_issue.title
      compare(issue, github_issue)
    end

    def changed?
      !@changed.empty?
    end

    private

    def compare(issue, github_issue)
      if @sync_assignee && issue.assignee != @assignee
        @changed << 'assignee'
        @assignee = issue.assignee
      end
      unless issue.new_title.nil?
        @changed << 'title'
        @title = issue.new_title
      end
      unless content_matches?(issue.content, @content)
        @changed << 'body'
        @content = issue.content
      end
    end

    def content_matches?(first, second)
      second.delete!("\r")
      first.gsub(/\[x\]/, '[ ]') == second.gsub(/\[x\]/, '[ ]')
    end
  end
end
