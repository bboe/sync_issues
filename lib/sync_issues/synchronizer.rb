require_relative 'comparison'
require_relative 'error'
require_relative 'label_sync'
require_relative 'parser'
require 'English'

module SyncIssues
  # Synchronizer is responsible for the actual synchronization.
  class Synchronizer
    def initialize(directory, repository_names, label_yaml: nil,
                   reset_labels: false, sync_assignees: true,
                   sync_labels: true, update_only: false)
      @github = SyncIssues.github
      @issues = issues(directory)
      @label_sync = LabelSync.new(@github, label_yaml)
      @repositories = repositories(repository_names)
      @reset_labels = reset_labels
      @sync_assignees = sync_assignees
      @sync_labels = sync_labels
      @update_only = update_only
    end

    def run
      puts "Synchronize #{@issues.count} issue#{@issues.count == 1 ? '' : 's'}"
      @repositories.each { |repository| synchronize(repository) }
    end

    private

    def issues(directory)
      unless File.directory?(directory)
        raise Error, "'#{directory}' is not a valid directory"
      end

      issues = Dir.glob(File.join(directory, '**/*')).sort.map do |entry|
        next unless entry.end_with?('.md') && File.file?(entry)
        begin
          Parser.new(File.read(entry)).issue
        rescue ParseError => exc
          puts "'#{entry}': #{exc}"
          nil
        end
      end.compact

      if issues.empty?
        raise Error, "'#{directory}' does not contain any .md files"
      end

      issues
    end

    def repositories(repository_names)
      repositories = repository_names.map do |repository_name|
        begin
          @github.repository(repository_name)
        rescue Error => exc
          puts "'#{repository_name}' #{exc}"
          nil
        end
      end.compact

      raise Error, 'No valid repositories specified' if repositories.empty?

      repositories
    end

    def synchronize(repository)
      puts "Repository: #{repository.full_name}"
      @label_sync.synchronize(repository) if @sync_labels

      existing_by_title = {}
      @github.issues(repository).each do |issue|
        existing_by_title[issue.title] = issue
      end

      @issues.each do |issue|
        if existing_by_title.include?(issue.title)
          update_issue(repository, issue, existing_by_title[issue.title])
        else
          create_issue(repository, issue)
        end
      end
    end

    private

    def create_issue(repository, issue)
      if @update_only || issue.new_title
        puts "Skipping create issue: #{issue.title}"
      else
        puts "Adding issue: #{issue.title}"
        @github.create_issue(repository, issue, @sync_assignees, @sync_labels)
      end
    end

    def update_issue(repository, issue, github_issue)
      comparison = Comparison.new(issue, github_issue,
                                  reset_labels: @reset_labels,
                                  sync_assignees: @sync_assignees,
                                  sync_labels: @sync_labels)
      return unless comparison.changed?

      changed = comparison.changed.join(', ')
      puts "Updating #{changed} on ##{github_issue.number}"
      @github.update_issue(repository, github_issue.number, comparison)
    end
  end
end
