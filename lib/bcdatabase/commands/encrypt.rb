require 'bcdatabase/commands'

module Bcdatabase::Commands
  class Encrypt
    def initialize(inputfile=nil, outputfile=nil)
      @input = inputfile
      @output = outputfile
    end

    def run
      inio =
        if @input
          open(@input, "r")
        else
          $stdin
        end
      # try to preserve the order by replacing everything using regexes
      contents = inio.read
      contents.gsub!(/\bpassword:(\s*)(\S+)\s*?$/) { "epassword:#{$1}#{Bcdatabase.encrypt($2)}" }
      outio =
        if @output
          open(@output, "w")
        else
          $stdout
        end
      outio.write(contents)
      outio.close
    end
  end
end
