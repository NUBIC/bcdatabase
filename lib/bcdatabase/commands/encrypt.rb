require 'bcdatabase/commands'

module Bcdatabase::Commands
  class Encrypt
    def initialize(inputfile=nil, outputfile=nil)
      @input = (Pathname.new(inputfile) if inputfile)
      @output = (Pathname.new(outputfile) if outputfile)
    end

    def run
      # try to preserve the order by replacing everything using regexes
      contents = inio.read
      contents.gsub!(/\bpassword:(\s*)(\S+)\s*?$/) { "epassword:#{$1}#{Bcdatabase.encrypt($2)}" }
      outio.write(contents)
      outio.close
    end

    private

    def inio
      @inio ||=
        if @input
          @input.open('r')
        else
          $stdin
        end
    end

    def outio
      @outio ||=
        if @output
          @output.dirname.mkpath
          @output.open('w')
        else
          $stdout
        end
    end
  end
end
