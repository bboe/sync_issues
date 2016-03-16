require_relative 'error'

module SyncIssues
  # Comparison represents differences between Issues (local and GitHub)
  class Comparison
    attr_reader :assignee, :changed, :content, :labels, :title

    def initialize(issue, github_issue, sync_assignee: false,
                   update_labels: false)
      @changed = []
      @assignee = github_issue.assignee && github_issue.assignee.login
      @content = github_issue.body
      @labels = github_issue.labels.map { |label| label[:name] }
      @title = github_issue.title
      compare(issue, sync_assignee, update_labels)
    end

    def changed?
      !@changed.empty?
    end

    private

    def compare(issue, sync_assignee, update_labels)
      if sync_assignee && issue.assignee != @assignee
        @changed << 'assignee'
        @assignee = issue.assignee
      end
      if update_labels && !issue.labels.nil? && !labels_match(issue.labels,
                                                              @labels)
        @changed << 'labels'
        @labels = issue.labels
      end
      unless issue.new_title.nil?
        @changed << 'title'
        @title = issue.new_title
      end
      return if content_matches?(issue.content, @content)
      @changed << 'body'
      @content = issue.content
    end

    def content_matches?(first, second)
      second.delete!("\r")
      first.gsub(/\[x\]/, '[ ]') == second.gsub(/\[x\]/, '[ ]')
    end

    def labels_match(first, second)
      # Label uniqueness is not case-sensitive.
      first.map(&:downcase) == second.map(&:downcase)
    end
  end
end
