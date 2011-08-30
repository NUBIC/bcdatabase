require File.expand_path("../spec_helper", File.dirname(__FILE__))

module Bcdatabase::Commands
  UTILITY_NAME = "bcdatabase-spec"
end

describe "CLI: bcdatabase" do
  before do
    pending('Issue #7') if RUBY_VERSION > '1.9'

    ENV["BCDATABASE_PATH"] = tmpdir + 'bcdb_specs'
    FileUtils.mkdir_p ENV["BCDATABASE_PATH"]
  end

  after(:each) do
    if RUBY_VERSION < '1.9'
      ENV["BCDATABASE_PATH"] = nil
    end
  end

  describe "encrypt" do
    before do
      enable_fake_cipherment
    end

    after do
      if RUBY_VERSION < '1.9'
        disable_fake_cipherment
      end
    end

    def bcdatabase_encrypt(infile)
      YAML::load(capture_std {
        Bcdatabase::Commands::Encrypt.new([File.join(ENV["BCDATABASE_PATH"], infile)]).main
      }[:out])
    end

    it "replaces password: clauses with epasswords" do
      temporary_yaml "plain", {
        "single" =>  {
          "password" => 'zanzibar'
        }
      }

      bcdatabase_encrypt('plain.yaml')['single']['epassword'].should == 'rabiznaz'
      bcdatabase_encrypt('plain.yaml')['single']['password'].should be_nil
    end

    it "leaves existing epasswords alone" do
      temporary_yaml "plain", {
        "single" =>  {
          "epassword" => 'etalocohc'
        }
      }

      bcdatabase_encrypt('plain.yaml')['single']['epassword'].should == 'etalocohc'
    end
  end

  describe "help" do
    def bcdatabase_help
      capture_std { Bcdatabase::Commands::Help.new([]).main }[:err]
    end

    it "includes an entry for itself" do
      bcdatabase_help.should =~ /help/
    end

    it "includes an entry for encrypt" do
      bcdatabase_help.should =~ /encrypt/
    end

    it "includes an entry for epass" do
      bcdatabase_help.should =~ /epass/
    end

    it "includes an entry for genkey" do
      bcdatabase_help.should =~ /gen-key/
    end
  end
end
