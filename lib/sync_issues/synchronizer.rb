module SyncIssues
  # Synchronizer is responsible for the actual synchronization.
  class Synchronizer
    def initialize(directory, repositories)
      @directory = check_directory(directory)
      @repositories = check_repositories(repositories)
    end

    def run
      puts "Sync #{@directory} to #{@repositories.inspect}."
    end

    private

    def check_directory(directory)
      directory
    end

    def check_repositories(repositories)
      repositories
    end
  end
end
