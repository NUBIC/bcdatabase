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

    desc 'epass [-]', 'Generates epasswords from database passwords'
    long_desc <<-DESC
      With no arguments, interactively prompts for passwords and
      prints the corresponding epassword entry.

      If the last argument is -, reads a newline-separated list of
      passwords from standard in and prints the corresponding
      epasswords to standard out.
    DESC
    def epass(arg=nil)
      Commands::Epass.new(arg == '-').run
    end

    desc 'gen-key [-]', 'Generates the bcdatabase shared key'
    long_desc <<-DESC
      Generates the key that is used to obscure epasswords. By
      default, the key will be generated in
      #{Bcdatabase.pass_file}.  If the last argument to this command
      is -, the key will be generated to standard out instead.

      CAUTION: writing to #{Bcdatabase.pass_file} may overwrite an
      existing bcdatabase key.  If that happens, you will need to
      reencrypt all the epasswords on this machine.
    DESC
    def gen_key(arg=nil)
      Commands::GenKey.new(arg == '-').run
    end

    no_tasks do
      # Add uniform exception handling
      [:encrypt, :epass, :gen_key].each do |original|
        alias_method "#{original}_without_rescue".to_sym, original

        class_eval <<-RUBY
          def #{original}(*args)
            #{original}_without_rescue(*args)
          rescue SystemCallError => e
            shell.say("\#{e.class}: \#{e}", :RED)
            exit(8)
          rescue Bcdatabase::Error => e
            shell.say(e.message, :RED)
            exit(4)
          rescue Commands::ForcedExit => e
            exit(e.code)
          end
        RUBY
      end
    end
  end
end
