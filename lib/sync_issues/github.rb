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

    def create_issue(repository, issue, add_assignee)
      kwargs = {}
      kwargs[:assignee] = issue.assignee if add_assignee
      @client.create_issue(repository.full_name, issue.title, issue.content,
                           **kwargs)
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

    def update_issue(repository, issue_number, title, content, assignee)
      @client.update_issue(repository.full_name, issue_number, title, content,
                           assignee: assignee)
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
