$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))

require 'bcdatabase'
require 'fileutils'
require 'pathname'

module Bcdatabase::Spec
  module Helpers
    def self.use_in(rspec_config)
      rspec_config.include self
      rspec_config.after do
        clear_tmpdir
      end
    end

    def tmpdir
      @tmpdir ||= Pathname.new(File.expand_path('../tmp', __FILE__)).tap do |tmp|
        tmp.mkpath
      end
    end

    def clear_tmpdir
      if @tmpdir
        @tmpdir.rmtree
      end
    end
    module_function :clear_tmpdir

    def temporary_yaml(name, hash)
      filename = "/#{ENV['BCDATABASE_PATH']}/#{name}.yaml"
      open(filename, "w") { |f| YAML.dump(hash, f) }
      filename
    end

    def capture_std
      so = StringIO.new
      se = StringIO.new
      [so, se].each do |s|
        s.set_encoding('ASCII-8BIT') if s.respond_to?(:set_encoding)
      end
      $stdout = so
      $stderr = se
      begin
        yield
        { :out => so.string, :err => se.string }
      rescue => e
        { :out => so.string, :err => se.string, :exception => e }
      end
    ensure
      $stdout = STDOUT
      $stderr = STDERR
    end

    def replace_stdin(*lines)
      $stdin = StringIO.new(lines.join("\n"))
      yield
    ensure
      $stdin = STDIN
    end

    def enable_fake_cipherment
      # replace real encryption methods with something predictable
      Bcdatabase.module_eval do
        class << self
          alias :encrypt_original :encrypt
          alias :decrypt_original :decrypt
          def encrypt(s); s.reverse; end
          def decrypt(s); s.reverse; end
        end
      end
    end

    def disable_fake_cipherment
      Bcdatabase.module_eval do
        class << self
          alias :encrypt :encrypt_original
          alias :decrypt :decrypt_original
        end
      end
    end
  end
end

RSpec.configure do |config|
  Bcdatabase::Spec::Helpers.use_in(config)
end
