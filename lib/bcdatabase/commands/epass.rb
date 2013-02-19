require 'bcdatabase/commands'

require 'highline'

module Bcdatabase::Commands
  class Epass
    def initialize(streaming, opts={})
      @streaming = streaming
      @echo = opts[:echo].nil? ? false : opts[:echo]
      @hl = HighLine.new($stdin, $stderr)
    end

    def run
      @streaming ? streamed : interactive
    end

    protected

    def streamed
      $stdin.readlines.each do |line|
        puts Bcdatabase.encrypt(line.chomp)
      end
    end

    def interactive
      loop do
        # The proc ensures that HighLine doesn't coerce the answer to
        # a HighLine::String.
        pass = @hl.ask("Password (^C to end): ", proc { |a| a }) do |q|
          # this is configurable because having it false hangs the
          # unit tests.
          q.echo = @echo
        end
        puts "  epassword: #{Bcdatabase.encrypt(pass)}"
      end
    rescue Interrupt
      $stderr.puts "Quit"
    rescue EOFError
      $stderr.puts "Quit"
    end
  end
end
