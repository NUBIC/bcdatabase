require File.expand_path("../spec_helper", File.dirname(__FILE__))

require "bcdatabase/commands"

describe "CLI: bcdatabase" do
  before(:each) do
    ENV["BCDATABASE_PATH"] = "/tmp/bcdb_specs"
    FileUtils.mkdir_p ENV["BCDATABASE_PATH"]
  end

  after(:each) do
    FileUtils.rm_rf ENV["BCDATABASE_PATH"]
    ENV["BCDATABASE_PATH"] = nil
  end

  describe "encrypt" do
    before do
      enable_fake_cipherment
    end

    after do
      disable_fake_cipherment
    end

    def bcdatabase_encrypt(infile)
      StringIO.open("", "w") do |io|
        $stdout = io
        Bcdatabase::Commands::Encrypt.new([File.join(ENV["BCDATABASE_PATH"], infile)]).main
        $stdout = STDOUT
        YAML::load(io.string)
      end
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
end