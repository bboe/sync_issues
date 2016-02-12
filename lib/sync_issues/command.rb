require 'docopt'
require 'octokit'
require_relative 'error'
require_relative 'synchronizer'
require_relative 'version'

module SyncIssues
  # Provides the command line interface to SyncIssues
  class Command
    DOC = <<-DOC
    sync_issues: A tool that synchronizes a local directory with GitHub issues.

    Usage:
      sync_issues [options] DIRECTORY REPOSITORY...
      sync_issues -h | --help
      sync_issues --version

    Options:
      -u --update  Only update existing issues.
      -h --help    Output this help information.
      --version    Output the sync_issues version (#{VERSION}).
    DOC

    def initialize
      @exit_status = 0
    end

    def run
      handle_args(Docopt.docopt(DOC, version: VERSION))
    rescue Docopt::Exit => exc
      exit_with_status(exc.message, exc.class.usage != '')
    rescue Error, Octokit::Unauthorized => exc
      exit_with_status(exc.message)
    end

    private

    def exit_with_status(message, condition = true)
      puts message
      @exit_status == 0 && condition ? 1 : @exit_status
    end

    def handle_args(options)
      SyncIssues.synchronizer(options['DIRECTORY'], options['REPOSITORY'],
                              update_only: options['--update']).run
      @exit_status
    end
  end
end
