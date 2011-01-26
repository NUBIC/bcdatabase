lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'bcdatabase/version'

Gem::Specification.new do |s|
  s.name = 'bcdatabase'
  s.version = Bcdatabase::VERSION
  s.summary = %Q{Server-central database configuration for rails and other ruby apps}
  s.description = %Q{bcdatabase is a tool for storing passwords and other database configuration information outside of your application source tree.}
  s.email = "rhett@detailedbalance.net"
  s.homepage = "http://github.com/rsutphin/bcdatabase"
  s.authors = ["Rhett Sutphin"]

  s.require_path = "lib"

  s.executables = ['bcdatabase']
  s.files = Dir.glob("{CHANGELOG.markdown,LICENSE,README.markdown,{bin,lib}/**/*}")

  s.add_dependency "activesupport", "~> 2.0"
  s.add_dependency "highline", "~> 1.6"

  s.add_development_dependency 'rspec', "~> 1.2"
end
