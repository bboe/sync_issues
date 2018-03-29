require_relative 'error'
require 'octokit'
require 'safe_yaml/load'

module SyncIssues
  # GitHub is responsible access to GitHub's API
  class GitHub
    attr_reader :client

    def initialize
      @client = Octokit::Client.new access_token: token
      @client.auto_paginate = true
    end

    def create_issue(repository, issue, add_assignees, add_labels)
      kwargs = {}
      kwargs[:assignee] = issue.assignees[0] if add_assignees
      kwargs[:labels] = issue.labels if add_labels
      new_issue = @client.create_issue(repository.full_name, issue.title,
                                       issue.content, **kwargs)
      if add_assignees && issue.assignees.size > 1
        @client.add_assignees(repository.full_name, new_issue.number,
                              issue.assignees[1..-1])
      end
    end

    def issues(repository)
      @client.issues(repository.full_name, state: :all)
    end

    def labels(repository)
      @client.labels(repository.full_name)
    end

    def repository(repository_name)
      @client.repository(repository_name)
    rescue Octokit::InvalidRepository => exc
      raise Error, exc.message
    rescue Octokit::NotFound
      raise Error, 'repository not found'
    end

    def update_issue(repository, issue_number, comparison)
      @client.update_issue(repository.full_name, issue_number,
                           comparison.title, comparison.content,
                           assignee: comparison.assignees[0],
                           labels: comparison.labels)
      if comparison.assignees.size > 1
        @client.add_assignees(repository.full_name, issue_number,
                              comparison.assignees[1..-1])
      end
    end

    private

    def token
      path = File.expand_path('~/.config/sync_issues.yaml')
      raise TokenError, "#{path} does not exist" unless File.exist?(path)
      SafeYAML.load(File.read(path))['token'].tap do |token|
        raise TokenError, "#{path} missing token attribute" if token.nil?
      end
    end
  end
end
