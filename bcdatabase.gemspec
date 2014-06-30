lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'bcdatabase/version'

Gem::Specification.new do |s|
  s.name = 'bcdatabase'
  s.version = Bcdatabase::VERSION
  s.summary = %Q{Server-central database configuration for rails and other ruby apps}
  s.description = %Q{bcdatabase is a tool for storing passwords and other configuration information outside of your application source tree.}
  s.email = "rhett@detailedbalance.net"
  s.homepage = "http://github.com/NUBIC/bcdatabase"
  s.authors = ["Rhett Sutphin"]

  s.require_paths = ["lib"]

  s.executables = ['bcdatabase']
  s.files = Dir.glob("{CHANGELOG.markdown,LICENSE,README.markdown,bcdatabase.gemspec,{bin,lib}/**/*}")

  s.add_dependency 'highline', '~> 1.5'
  s.add_dependency 'thor', '~> 0.14'

  s.add_development_dependency 'bundler', '~> 1.0', '>= 1.0.15'
  s.add_development_dependency 'rake', '~> 0.9.2'
  s.add_development_dependency 'rspec','~> 2.6'
  s.add_development_dependency "ci_reporter", "~> 1.6"
  s.add_development_dependency 'yard', '~> 0.7.2'
end
