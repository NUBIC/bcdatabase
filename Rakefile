require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake/rdoctask'
require 'spec/rake/spectask'
require 'ci/reporter/rake/rspec'

Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

namespace :ci do
  ENV["CI_REPORTS"] = "reports/spec-xml"

  desc "Run specs for CI"
  task :spec => ['ci:setup:rspec', 'rake:spec']
end

task :default => :spec
