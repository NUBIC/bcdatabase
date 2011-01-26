require File.expand_path("spec_helper", File.dirname(__FILE__))

describe Bcdatabase do
  before(:each) do
    ENV["BCDATABASE_PATH"] = "/tmp/bcdb_specs"
    FileUtils.mkdir_p ENV["BCDATABASE_PATH"]
  end

  after(:each) do
    FileUtils.rm_rf ENV["BCDATABASE_PATH"]
    ENV["BCDATABASE_PATH"] = nil
  end

  describe "cipherment" do
    before(:all) do
      keyfile = "/tmp/bcdb-spec-key"
      open(keyfile, 'w') { |f| f.write "01234567890123456789012345678901" }
      ENV["BCDATABASE_PASS"] = keyfile
    end

    after(:all) do
      FileUtils.rm ENV["BCDATABASE_PASS"]
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
        ::RAILS_ENV = "staging"
      end

      after do
        Object.class_eval { remove_const "RAILS_ENV" }
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
