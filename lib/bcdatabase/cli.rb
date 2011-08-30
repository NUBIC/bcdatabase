require 'bcdatabase'
require 'thor'

module Bcdatabase
  class CLI < Thor
    desc "encrypt [INPUT [OUTPUT]]",
      "Encrypts every password in a bcdatabase YAML file."
    long_desc <<-DESC
      This command finds all the keys named 'password' in the input
      YAML and substitutes appropriate 'epassword' keys.

      If inputfile is specified, the source will be that file. If not,
      the source will be standard in.

      If inputfile and outputfile are specified, the new file will be
      written to the output file. Otherwise the output will go to
      standard out. Input and output may be the same file.

      You can't read from standard in and write to a file directly;
      use shell file redirection if you need to do that.
    DESC
    def encrypt(inputfile=nil, outputfile=nil)
      Commands::Encrypt.new(inputfile, outputfile).run
    end
  end
end
