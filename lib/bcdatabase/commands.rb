require 'rubygems'
require 'fileutils'
require 'highline'
require 'active_support'
require 'active_support/core_ext/string/inflections'
require 'bcdatabase'

HL = HighLine.new

module Bcdatabase::Commands
  autoload :Encrypt, 'bcdatabase/commands/encrypt'

  class Base
    protected

    def self.usage(use)
      "usage: #{UTILITY_NAME} #{use}"
    end

    def self.help_message(use)
      msg = [ "#{command_name}: #{summary}", usage(use), "" ]
      yield msg if block_given?
      msg.join("\n")
    end
  end

  class Epass < Base
    def initialize(argv)
      @streaming = argv[-1] == '-'
    end

    def self.summary
      "Generate epasswords from individual database passwords"
    end

    def self.help
      help_message("epass [-]") do |msg|
        msg << "With no arguments, interactively prompts for passwords and"
        msg << "  prints the corresponding epassword entry."
        msg << ""
        msg << "If the last argument is -, reads a newline-separated list"
        msg << "  of passwords from standard in and prints the corresponding "
        msg << "  epasswords to standard out."
      end
    end

    def main
      @streaming ? streamed : interactive
    end

    private

    def streamed
      $stdin.readlines.each do |line|
        puts Bcdatabase.encrypt(line.chomp)
      end
      0
    end

    def interactive
      begin
        loop do
          pass = HL.ask("Password (^C to end): ") do |q|
            q.echo = false
          end
          puts "  epassword: #{Bcdatabase.encrypt(pass)}"
        end
      rescue Interrupt
        puts "\nQuit"
      end
      0
    end
  end

  class GenKey < Base
    def initialize(argv)
      @stream = argv[-1] == '-'
    end

    def self.summary
      "Generate a key for bcdatabase to use"
    end

    def self.help
      help_message("gen-key [-]") do |msg|
        msg << "By default, the key will be generated in "
        msg << "  #{Bcdatabase.pass_file}.  If the last argument to this"
        msg << "  command is -, the key will be generated to standard out"
        msg << "  instead."
        msg << ""
        msg << "CAUTION: writing to #{Bcdatabase.pass_file} may overwrite"
        msg << "  an existing bcdatabase key.  If that happens, you will"
        msg << "  need to reencrypt all the epasswords on this machine."
      end
    end

    def main
      key = random_key(128)
      outio =
        if @stream
          $stdout
        else
          file = Bcdatabase.pass_file
          if File.exist?(file)
            sure = HL.ask("This operation will overwrite the existing pass file.\n  Are you sure you want to do that? ", %w{yes no}) do |q|
              q.case = :down
            end
            unless sure == 'yes'
              exit(0)
            end
          end
          open(file, "w")
        end
      outio.write key
      outio.close
      0
    end

    private

    def random_key(length)
      k = ""
      # This is probably not going to work in ruby 1.9
      until k.size == length; k << rand(126 - 32) + 32; end
      k
    end
  end
end
