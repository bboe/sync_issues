require_relative 'error'

module SyncIssues
  # Comparison represents differences between Issues (local and GitHub)
  class Comparison
    attr_reader :assignee, :changed, :content, :labels, :title

    def initialize(issue, github_issue, reset_labels: false,
                   sync_assignee: true, sync_labels: true)
      @changed = []
      @assignee = github_issue.assignee && github_issue.assignee.login
      @content = github_issue.body
      @labels = github_issue.labels.map { |label| label[:name] }
      @title = github_issue.title
      compare(issue, reset_labels, sync_assignee, sync_labels)
    end

    def changed?
      !@changed.empty?
    end

    private

    def compare(issue, reset_labels, sync_assignee, sync_labels)
      if sync_assignee && issue.assignee != @assignee
        @changed << 'assignee'
        @assignee = issue.assignee
      end
      if sync_labels && update_label?(issue, reset_labels)
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

    def labels_match?(new_labels)
      # Label uniqueness is not case-sensitive.
      new_labels.map(&:downcase) == @labels.map(&:downcase)
    end

    def update_label?(issue, reset_labels)
      !issue.labels.nil? && (reset_labels && !labels_match?(issue.labels) ||
                             @labels.size == 0)
    end
  end
end
