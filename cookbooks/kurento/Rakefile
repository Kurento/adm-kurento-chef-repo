# chefspec task against spec/*_spec.rb
require 'rspec/core/rake_task'

desc "Runs foodcritic linter"
task :foodcritic do
  if Gem::Version.new("1.9.2") <= Gem::Version.new(RUBY_VERSION.dup)
    sh "foodcritic ."
  else
    puts "WARN: foodcritic run is skipped as Ruby #{RUBY_VERSION} is < 1.9.2."
  end
end

desc "Runs chefspec on all the cookbooks."
task :chefspec do
  sh "rspec . --format RspecJunitFormatter --out test-results.xml"
end

task :default => ['foodcritic', 'chefspec']
