require 'yaml'
require 'openssl'
require 'digest/sha2'
require 'base64'

# Requiring just extract_options doesn't work on AS 2.3.
require 'active_support/core_ext/array'

module Bcdatabase
  autoload :VERSION,  'bcdatabase/version'
  autoload :Commands, 'bcdatabase/commands'

  DEFAULT_BASE_PATH = File.join('/', 'etc', 'nubic', 'db')
  DEFAULT_PASS_FILE = File.join('/', 'var', 'lib', 'nubic', 'db.pass')
  CIPHER = 'aes-256-ecb'

  class << self
    ##
    # The main entry point for Bcdatabase.
    #
    # @overload load(options={})
    #   (See other alternative for option definitions.)
    #   @return [DatabaseConfigurations] a new instance using the
    #     default path.
    # @overload load(path=nil, options={})
    #   @param [String,nil] path the directory to load from. If nil,
    #     will use the value in the environment variable
    #     `BCDATABASE_PATH`. If that's nil, too, it will use the
    #     default path.
    #   @param [Hash,nil] options additional options affecting the
    #     load behavior.
    #   @option options :transforms [Array<Symbol, #call>] ([]) Custom
    #     transforms. This can either be a symbol naming a
    #     {DatabaseConfigurations.BUILT_IN_TRANSFORMS built-in
    #     transform} or a callable which is the transform itself. A
    #     transform is a function that takes three arguments (the
    #     entry itself, the entry name, and the group name) and
    #     returns a new copy, modified as desired. It may also return
    #     nil to indicate that it doesn't wish to make any changes.
    #   @return [DatabaseConfigurations] a new instance reflecting
    #     the selected path.
    def load(*args)
      options = args.extract_options!
      path ||= (args.first || base_path)
      files = Dir.glob(File.join(path, "*.yml")) + Dir.glob(File.join(path, "*.yaml"))
      DatabaseConfigurations.new(files, options[:transforms] || [])
    end

    ##
    # @private exposed for collaboration
    def encrypt(s)
      Base64.encode64(encipher(:encrypt, s)).strip
    end

    ##
    # @private exposed for collaboration
    def decrypt(s)
      encipher(:decrypt, Base64.decode64(s))
    end

    def pass_file
      ENV["BCDATABASE_PASS"] || DEFAULT_PASS_FILE
    end

    private

    # based on http://snippets.dzone.com/posts/show/576
    def encipher(direction, s)
      # the order of operations here is very important
      c = OpenSSL::Cipher::Cipher.new(CIPHER)
      c.send direction
      c.key = pass
      t = c.update(s)
      t << c.final
    end

    def pass
      return @pass if instance_variable_defined? :@pass

      contents = open(pass_file).read.chomp
      # This code may not work correctly on Ruby 1.9
      if contents.size == 32
        @pass = contents
      else
        @pass = Digest::SHA256.digest(contents)
      end
    end

    def base_path
      ENV["BCDATABASE_PATH"] || DEFAULT_BASE_PATH
    end
  end

  ##
  # The set of groups and entries returned by one call to {Bcdatabase.load}.
  class DatabaseConfigurations
    BUILT_IN_TRANSFORMS = {
      :key_defaults => lambda { |entry, name, group|
        { 'username' => name, 'database' => name }.merge(entry)
      },
      :decrypt => lambda { |entry, name, group|
        entry.merge({ 'password' => Bcdatabase.decrypt(entry['epassword']) }) if entry['epassword']
      }
    }

    ##
    # Creates a configuration from a set of YAML files.
    #
    # General use of the library should not use this method, but
    # instead should use {Bcdatabase.load}.
    def initialize(files, transforms=[])
      @transforms = ([:key_defaults, :decrypt] + transforms).collect do |t|
        case t
        when Symbol
          BUILT_IN_TRANSFORMS[t] or fail "No built-in transform named #{t.inspect}"
        else
          fail 'Transforms must by callable' unless t.respond_to?(:call)
          t
        end
      end
      @files = files
      @map = { }
      files.each do |filename|
        name = File.basename(filename).gsub(/\.ya?ml/, '')
        @map[name] = YAML.load(File.open(filename))
      end
    end

    ##
    # @return [Hash] the entry for the given group and name after all
    #   transformation is complete.
    def [](groupname, dbname)
      create_entry(groupname.to_s, dbname.to_s)
    end

    ##
    # This method implements the Rails database.yml integration
    # described in full in the {file:README.markdown}.
    #
    # @return [String] a YAMLized view of a configuration entry.
    def method_missing(name, *args)
      groupname = (args[0] or raise "Database configuration group not specified for #{name}")
      dbname = (args[1] or raise "Database entry name not specified for #{name}")
      n = name.to_s
      begin
        unseparated_yaml(n => self[groupname, dbname])
      rescue Bcdatabase::Error => e
        if ENV['RAILS_ENV'] == n
          raise e
        else
          # Not using that configuration right now, so return a dummy instead
          # of throwing an exception
          unseparated_yaml(n => { 'error' => e.message })
        end
      end
    end

    private

    def create_entry(groupname, dbname)
      group = @map[groupname] or raise Error.new("No database configuration group named #{groupname.inspect} found.  (Found #{@map.keys.inspect}.)")
      db = group[dbname] or raise Error.new("No database entry for #{dbname.inspect} in #{groupname}")
      base = (group['defaults'] || {}).
        merge(group['default'] || {}).
        merge(db)
      @transforms.inject(base) do |result, transform|
        transform.call(result, dbname, groupname) || result
      end
    end

    def unseparated_yaml(arg)
      arg.to_yaml.gsub(/^---.*\n/, '')
    end
  end

  class Error < Exception; end
end
