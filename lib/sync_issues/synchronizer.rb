require_relative 'error'

module SyncIssues
  # Synchronizer is responsible for the actual synchronization.
  class Synchronizer
    def initialize(directory, repositories)
      @files = file_list(directory)
      @repositories = check_repositories(repositories)
    end

    def run
      puts "Sync #{@files.inspect} to #{@repositories.inspect}."
    end

    private

    def file_list(directory)
      unless File.directory?(directory)
        raise Error, "'#{directory}' is not a valid directory"
      end

      files = Dir.glob(File.join(directory, '**/*')).select do |entry|
        entry.end_with?('.md') && File.file?(entry)
      end

      if files.empty?
        raise Error, "'#{directory}' does not contain any .md files"
      end

      files
    end

    def check_repositories(repositories)
      repositories
    end
  end
end
