source "http://rubygems.org"

gemspec

group :development do
  # For yard's markdown support
  platforms :jruby do; gem 'maruku'; end
  platforms :ruby_18, :ruby_19 do; gem 'rdiscount'; end
end

# This is specified here rather than in the gemspec so as not to have
# to release multiple versions of the gem. The requirement is
# documented in the README.
gem 'jruby-openssl', :platform => 'jruby'
