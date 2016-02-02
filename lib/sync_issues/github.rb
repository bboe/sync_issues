require_relative 'error'
require 'octokit'
require 'safe_yaml/load'

module SyncIssues
  # GitHub is responsible access to GitHub's API
  class GitHub
    def initialize
      @client = Octokit::Client.new access_token: token
    end

    def create_issue(repository, issue)
      @client.create_issue(repository.full_name, issue.title, issue.content)
    end

    def issues(repository)
      @client.issues(repository)
    end

    def repository(repository_name)
      @client.repository(repository_name)
    rescue Octokit::InvalidRepository => exc
      raise Error, exc.message
    rescue Octokit::NotFound
      raise Error, 'repository not found'
    end

    def update_issue(repository, github_issue, issue)
      @client.update_issue(repository.full_name, github_issue.number,
                           issue.new_title || issue.title, issue.content)
    end

    private

    def token
      path = File.expand_path('~/.config/sync_issues.yaml')
      SafeYAML.load(File.read(path))['token']
    end
  end
end
