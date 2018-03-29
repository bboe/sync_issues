require_relative 'lib/sync_issues/version'

Gem::Specification.new do |s|
  s.author = 'Bryce Boe'
  s.description = <<-EOF
    sync_issues is a ruby gem to that allows the easy creation and
    synchronization of issues on GitHub with structured local data.
  EOF
  s.email = 'bryce.boe@appfolio.com'
  s.executables = %w(sync_issues)
  s.files = Dir.glob('{bin,lib}/**/*') + %w(LICENSE.txt README.md)
  s.homepage = 'https://github.com/bboe/sync_issues'
  s.license = 'Simplified BSD'
  s.name = 'sync_issues'
  s.post_install_message = 'Happy syncing!'
  s.summary = 'A tool that synchronizes a local directory with GitHub issues.'
  s.version = SyncIssues::VERSION

  s.add_runtime_dependency 'docopt', '~> 0.5'
  s.add_runtime_dependency 'octokit', '~> 4.8'
  s.add_runtime_dependency 'safe_yaml', '~> 1.0'
end
