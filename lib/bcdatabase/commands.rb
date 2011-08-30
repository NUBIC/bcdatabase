require 'bcdatabase'

module Bcdatabase::Commands
  autoload :Encrypt, 'bcdatabase/commands/encrypt'
  autoload :Epass,   'bcdatabase/commands/epass'
  autoload :GenKey,  'bcdatabase/commands/gen_key'

  class ForcedExit < StandardError
    attr_reader :code

    def initialize(code)
      @code = code
    end
  end
end
