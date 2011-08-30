require File.expand_path('../../../spec_helper', __FILE__)

module Bcdatabase::Commands
  describe Encrypt do
    let(:pprod_path) { File.join(ENV['BCDATABASE_PATH'], 'pprod.yaml') }

    before do
      enable_fake_cipherment
      ENV['BCDATABASE_PATH'] = (tmpdir + 'base').tap { |d| d.mkpath }

      temporary_yaml 'pprod', {
        'wh' => {
          'password' => 'zanzibar'
        },
        'app' => {
          'epassword' => 'etalocohc'
        }
      }
    end

    after do
      ENV['BCDATABASE_PATH'] = nil
      disable_fake_cipherment
    end

    def run_with(inputfile, outputfile=nil)
      capture_std do
        Encrypt.new(inputfile, outputfile).run
      end
    end

    def run_with_input(*lines)
      replace_stdin(*lines) do
        capture_std do
          Encrypt.new.run
        end
      end
    end

    shared_examples 'general behavior' do
      let(:yaml_output) { YAML.load(output) }

      it 'reads from the appropriate input' do
        output.should =~ /wh:/
      end

      it 'encrypts the password' do
        yaml_output['wh']['epassword'].should == 'rabiznaz'
      end

      it 'removes the unencrypted password' do
        yaml_output['wh'].should_not have_key('password')
      end

      it 'leaves any existing epasswords alone' do
        yaml_output['app']['epassword'].should == 'etalocohc'
      end
    end

    describe 'with zero arguments' do
      subject { run_with_input('wh:', '  password: zanzibar', 'app:', '  epassword: etalocohc') }

      let(:output) { subject[:out] }

      include_examples 'general behavior'
    end

    describe 'with one argument' do
      subject { run_with(pprod_path) }

      let(:output) { subject[:out] }

      include_examples 'general behavior'
    end

    describe 'with two arguments' do
      subject { run_with(pprod_path, out_path) }

      let(:out_path) { tmpdir + 'encrypted.yml' }
      let(:output) { subject; File.read(out_path) }

      include_examples 'general behavior'
    end
  end
end
