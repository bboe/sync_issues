require_relative 'error'
require_relative 'parser'
require 'English'

module SyncIssues
  # Synchronizer is responsible for the actual synchronization.
  class Synchronizer
    def initialize(directory, repository_names)
      @issues = issues(directory)
      @repositories = repositories(repository_names)
    end

    def run
      puts "Synchronize #{@issues.count} issue#{@issues.count == 1 ? '' : 's'}"
      @issues.each { |issue| puts " * #{issue.title}" }
      @repositories.each { |repository| synchronize(repository) }
    end

    private

    def issues(directory)
      unless File.directory?(directory)
        raise Error, "'#{directory}' is not a valid directory"
      end

      issues = Dir.glob(File.join(directory, '**/*')).map do |entry|
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
          SyncIssues.github.repository(repository_name)
        rescue Error => exc
          puts "'#{repository_name}' #{exc}"
          nil
        end
      end.compact

      raise Error, 'No valid repositories specified' if repositories.empty?

      repositories
    end

    def synchronize(repository)
      puts "Repository: #{repository.name}"

      existing_by_title = {}
      SyncIssues.github.issues(repository.full_name).each do |issue|
        existing_by_title[issue.title] = issue
      end

      @issues.each do |issue|
        if existing_by_title.include?(issue.title)
          puts "Skipping existing issue: #{issue.title}"
          next
        end
        puts "Adding issue: #{issue.title}"
        SyncIssues.github.create_issue(repository, issue)
      end
    end
  end
end
