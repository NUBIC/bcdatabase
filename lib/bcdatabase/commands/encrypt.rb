require 'bcdatabase/commands'

module Bcdatabase::Commands
  class Encrypt
    def initialize(inputfile=nil, outputfile=nil)
      @input = (Pathname.new(inputfile) if inputfile)
      @output = (Pathname.new(outputfile) if outputfile)
    end

    def run
      begin
        # try to preserve the order by replacing everything using regexes
        contents = inio.read
        contents.gsub!(/\bpassword:.*?$/) { |line|
          "epassword: #{Bcdatabase.encrypt(YAML.load(line)['password']).inspect}"
        }
        outio.write(contents)
      ensure
        @inio.close if @close_in && @inio
        @outio.close if @close_out && @outio
      end
    end

    private

    def inio
      @inio ||=
        if @input
          @close_in = true
          @input.open('r')
        else
          $stdin
        end
    end

    def outio
      @outio ||=
        if @output
          @output.dirname.mkpath
          @close_out = true
          @output.open('w')
        else
          $stdout
        end
    end
  end
end
