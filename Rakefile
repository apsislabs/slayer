require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

if defined? Chandler
  # Set Chandler options
  Chandler::Tasks.configure do |config|
    config.changelog_path = 'CHANGELOG.md'
    config.github_repository = 'apsislabs/slayer'
  end

  # Add chandler as a prerequisite for `rake release`
  task 'release:rubygem_push' => 'chandler:push'
end

task default: :spec
