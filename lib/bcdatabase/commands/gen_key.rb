require 'bcdatabase/commands'
require 'highline'

module Bcdatabase::Commands
  class GenKey
    def initialize(streaming)
      @streaming = streaming
      @hl = HighLine.new($stdin, $stderr)
    end

    def run
      begin
        key = random_key(128)
        outio.write key
      ensure
        @outio.close if @outio
      end
    end

    private

    def random_key(length)
      (1..length).collect { rand(255) }.pack('C*')
    end

    def outio
      @outio ||=
        if @streaming
          $stdout
        else
          open_key_file
        end
    end

    def open_key_file
      filename = Bcdatabase.pass_file
      if File.exist?(filename)
        unless @hl.agree("This operation will overwrite the existing pass file.\n  Are you sure you want to do that? ")
          raise ForcedExit.new(1)
        end
      end
      open(filename, 'w')
    end
  end
end
