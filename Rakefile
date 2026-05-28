require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

begin
  require "standard/rake"
rescue LoadError
  # Standard not available
end

task default: [:standard, :spec]
