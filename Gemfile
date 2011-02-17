source "http://rubygems.org"

gemspec

# for testing against different major releases of ActiveSupport
if ENV['ACTIVESUPPORT_VERSION']
  version = case ENV['ACTIVESUPPORT_VERSION']
            when /2.3$/ then '~> 2.3.0'
            when /3.0$/ then '~> 3.0'
            else raise "Unsupported ActiveSupport version #{ENV['ACTIVESUPPORT_VERSION']}"
            end

  gem 'activesupport', version
end
