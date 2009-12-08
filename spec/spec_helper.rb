$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'bcdatabase'
require 'rubygems'
require 'fileutils'

def temporary_yaml(name, hash)
  filename = "/#{ENV['BCDATABASE_PATH']}/#{name}.yaml"
  open(filename, "w") { |f| YAML.dump(hash, f) }
  filename
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
