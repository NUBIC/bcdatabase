require File.expand_path("spec_helper", File.dirname(__FILE__))

describe Bcdatabase do
  before(:each) do
    ENV["BCDATABASE_PATH"] = (tmpdir + 'bcdb_specs').to_s
    FileUtils.mkdir_p ENV["BCDATABASE_PATH"]
  end

  after(:each) do
    FileUtils.rm_rf ENV["BCDATABASE_PATH"]
    ENV["BCDATABASE_PATH"] = nil
  end

  describe "cipherment" do
    let(:keyfile) { tmpdir + 'bcdb-spec-key' }

    before do
      open(keyfile, 'w') { |f| f.write "01234567890123456789012345678901" }
      ENV["BCDATABASE_PASS"] = keyfile.to_s
    end

    after do
      ENV["BCDATABASE_PASS"] = nil
    end

    it "should be reversible" do
      e = Bcdatabase.encrypt("riboflavin")
      Bcdatabase.decrypt(e).should == "riboflavin"
    end

    it "should permute the input" do
      Bcdatabase.encrypt("zanzibar").should_not == "zanzibar"
    end

    it "should do more than just encode" do
      Bcdatabase.encrypt("zanzibar").should_not == Base64.encode64("zanzibar")
    end

    context 'when the keyfile does not exist' do
      let(:bad_keyfile) { tmpdir + 'nothing' + 'here.key' }

      before do
        ENV['BCDATABASE_PASS'] = bad_keyfile.to_s
      end

      shared_examples 'ciphering without a keyfile' do
        let(:result) {
          capture_std do
            Bcdatabase.send(method, datum)
          end
        }

        it 'throws an exception' do
          result[:exception].should be_a Bcdatabase::Error
        end

        it 'does not print anything on STDOUT' do
          result[:out].should == ''
        end

        it 'does not print anything on STDERR' do
          result[:err].should == ''
        end

        describe 'the message' do
          let(:message) { result[:exception].message }

          it 'mentions the problem' do
            message.should =~ /Bcdatabase keyfile #{bad_keyfile} is not readable/
          end

          it 'mentions gen-key' do
            message.should =~ /bcdatabase gen-key/
          end

          it 'mentions the BCDATABASE_PASS env var' do
            message.should =~ /BCDATABASE_PASS/
          end

          it 'suggests checking permissions' do
            message.should =~ /permissions/
          end
        end
      end

      describe 'Bcdatabase.encrypt' do
        let(:method) { :encrypt }
        let(:datum) { 'zanzibar' }

        include_examples 'ciphering without a keyfile'
      end

      describe 'Bcdatabase.decrypt' do
        let(:method) { :decrypt }
        let(:datum) { Base64.encode64('zanzibar') }

        include_examples 'ciphering without a keyfile'
      end
    end
  end

  describe "loading" do
    it "should read simple YAML" do
      temporary_yaml "simple", {
        "single" =>  {
          "adapter" => "foo", "username" => "baz"
        }
      }
      bcdb = Bcdatabase.load
      bcdb[:simple, :single]['adapter'].should == "foo"
      bcdb[:simple, :single]['username'].should == "baz"
    end

    it "should read and expose multiple groups from multiple files" do
      temporary_yaml "one", {
        "first" => { "dc" => "etc" }
      }
      temporary_yaml "two", {
        "fourth" => { "dc" => "etc" }
      }
      bcdb = Bcdatabase.load
      bcdb['one', 'first'].should_not be_nil
      bcdb['two', 'fourth'].should_not be_nil
    end

    it "should merge defaults from 'defaults'" do
      temporary_yaml "defaulted", {
        "defaults" => {
          "database" => "postgresql"
        },
        "real" => {
          "password" => "frood"
        }
      }
      bcdb = Bcdatabase.load
      bcdb['defaulted', 'real']['password'].should == 'frood'
      bcdb['defaulted', 'real']['database'].should == 'postgresql'
    end

    it "should merge defaults from 'default'" do
      temporary_yaml "singular", {
        "default" => {
          "adapter" => "three-eighths"
        },
        "real" => {
          "password" => "frood"
        }
      }
      bcdb = Bcdatabase.load
      bcdb['singular', 'real']['adapter'].should == 'three-eighths'
    end

    it "should preserve values overridden from defaults" do
      temporary_yaml "jam", {
        "default" => {
          "adapter" => "three-eighths"
        },
        "standard" => {
          "password" => "frood"
        },
        "custom" => {
          "adapter" => "five-sixteenths",
          "password" => "lazlo"
        }
      }
      bcdb = Bcdatabase.load
      bcdb['jam', 'standard']['adapter'].should == 'three-eighths'
      bcdb['jam', 'custom']['adapter'].should == 'five-sixteenths'
    end

    it "should default the username to the entry name" do
      temporary_yaml "scran", {
        "jim" => { "password" => "leather" }
      }
      bcdb = Bcdatabase.load
      bcdb['scran', 'jim']['username'].should == 'jim'
      bcdb['scran', 'jim']['password'].should == 'leather'
    end

    it "should default the database name to the entry name" do
      temporary_yaml "scran", {
        "jim" => { "password" => "leather" }
      }
      bcdb = Bcdatabase.load
      bcdb['scran', 'jim']['database'].should == 'jim'
      bcdb['scran', 'jim']['password'].should == 'leather'
    end

    it "should not default the database name if there's an explicit database name" do
      temporary_yaml "scran", {
        "jim" => {
          "password" => "leather",
          "database" => "james"
        }
      }
      bcdb = Bcdatabase.load
      bcdb['scran', 'jim']['database'].should == 'james'
      bcdb['scran', 'jim']['password'].should == 'leather'
    end

    it "should not default the database name to the entry name if there's a default database name" do
      temporary_yaml "scran", {
        "default" => {
          "database" => "//localhost:345/etc"
        },
        "jim" => {
          "password" => "leather",
        }
      }
      bcdb = Bcdatabase.load
      bcdb['scran', 'jim']['database'].should == '//localhost:345/etc'
      bcdb['scran', 'jim']['password'].should == 'leather'
    end

    it "should use an explicit username instead of the entry name if provided" do
      temporary_yaml "scran", {
        "jim" => {
          "username" => "james",
          "password" => "earldom"
        }
      }
      bcdb = Bcdatabase.load
      bcdb['scran', 'jim']['username'].should == 'james'
      bcdb['scran', 'jim']['password'].should == 'earldom'
    end

    describe 'with an empty stanza' do
      before do
        temporary_yaml 'scran', "default:\n  host: foo\nempty:\n"
        @bcdb = Bcdatabase.load
      end

      it 'uses the default database key' do
        @bcdb['scran', 'empty']['database'].should == 'empty'
      end

      it 'uses the default username' do
        @bcdb['scran', 'empty']['username'].should == 'empty'
      end

      it 'uses an explicit default' do
        @bcdb['scran', 'empty']['host'].should == 'foo'
      end
    end

    describe "with encrypted passwords" do
      before do
        enable_fake_cipherment
      end

      after do
        disable_fake_cipherment
      end

      it "should decrypt and expose the password" do
        temporary_yaml "secure", {
          "safe" => {
            "epassword" => "moof"
          }
        }
        bcdb = Bcdatabase.load
        bcdb['secure', 'safe']['password'].should == "foom"
      end

      it "should prefer the decrypted version of an epassword" do
        temporary_yaml "secure", {
          "safe" => {
            "password" => "fake",
            "epassword" => "moof"
          }
        }
        bcdb = Bcdatabase.load
        bcdb['secure', 'safe']['password'].should == "foom" # not "fake"
      end
    end

    describe 'with custom transform' do
      let(:transform) {
        lambda do |entry, name, group|
          entry.merge('foo' => ['baz', name, group])
        end
      }

      it 'applies the transform' do
        temporary_yaml "scran", {
          "default" => {
            "database" => "//localhost:345/etc"
          },
          "jim" => {
            "password" => "leather",
          }
        }

        bcdb = Bcdatabase.load(:transforms => [transform])
        bcdb['scran', 'jim']['foo'].should == ['baz', 'jim', 'scran']
      end
    end

    describe 'for datamapper' do
      it 'uses the datamapper adapter, if provided' do
        temporary_yaml 'foo', {
          'aleph' => {
            'datamapper_adapter' => 'postgres',
            'adapter' => 'postgresql'
          }
        }
        bcdb = Bcdatabase.load(:transforms => [:datamapper])
        bcdb['foo', 'aleph']['adapter'].should == 'postgres'
      end

      it 'uses the named adapter if no datamapper adapter is provided' do
        temporary_yaml 'foo', {
          'aleph' => {
            'adapter' => 'postgresql'
          }
        }
        bcdb = Bcdatabase.load(:transforms => [:datamapper])
        bcdb['foo', 'aleph']['adapter'].should == 'postgresql'
      end

      it 'copies an arbitrary, datamapper-prefixed key to the no-prefix equivalent' do
        temporary_yaml 'foo',  {
          'aleph' => {
            'datamapper_preference' => 'flight',
            'preference' => 'invisibility'
          }
        }
        bcdb = Bcdatabase.load(:transforms => [:datamapper])
        bcdb['foo', 'aleph']['preference'].should == 'flight'
      end
    end

    describe 'with a JRuby adapter' do
      let(:bcdb) { Bcdatabase.load }

      before do
        temporary_yaml 'foo', {
          'aleph' => {
            'jruby_adapter' => 'jdbcpostgresql',
            'adapter' => 'postgresql'
          }
        }
      end

      if RUBY_PLATFORM =~ /java/
        it 'uses it in JRuby' do
          bcdb['foo', 'aleph']['adapter'].should == 'jdbcpostgresql'
        end
      else
        it 'does not use it on other platforms' do
          bcdb['foo', 'aleph']['adapter'].should == 'postgresql'
        end
      end
    end
  end

  describe "for database.yml" do
    before do
      temporary_yaml "scran", {
        "jim" => {
          "username" => "james",
          "password" => "earldom"
        },

        "dwide" => {
          "username" => "dwight",
          "password" => "help"
        }
      }
      @bcdb = Bcdatabase.load
    end

    describe "the yaml for a valid reference" do
      before do
        @yaml = @bcdb.development(:scran, :jim)
        @actual = YAML.load(@yaml)
      end

      it "isn't a separated YAML doc" do
        @yaml.should_not =~ /---/
      end

      it "has a single top-level key" do
        @actual.keys.should == ["development"]
      end

      it "reflects the selected configuration" do
        @actual['development']['username'].should == 'james'
        @actual['development']['password'].should == 'earldom'
      end
    end

    describe "an invalid reference" do
      before do
        @original_rails_env, ENV['RAILS_ENV'] = ENV['RAILS_ENV'], 'staging'
      end

      after do
        ENV['RAILS_ENV'] = @original_rails_env
      end

      describe "for the current RAILS_ENV" do
        it "allows the exception through" do
          lambda { @bcdb.staging(:scran, :phil) }.should raise_error
        end
      end

      describe "for a different RAILS_ENV" do
        it "does not throw an exception" do
          lambda { @bcdb.production(:scran, :phil) }.should_not raise_error
        end

        it "includes the error in the resulting hash" do
          @bcdb.production(:scran, :phil).should =~ / error: No database entry for \"phil\" in scran/
        end
      end
    end
  end
end
