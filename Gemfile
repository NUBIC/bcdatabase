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

group :development do
  # For yard's markdown support
  platforms :jruby do; gem 'maruku'; end
  platforms :ruby_18, :ruby_19 do; gem 'rdiscount'; end
end
