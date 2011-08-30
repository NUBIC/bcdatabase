require File.expand_path('../../../spec_helper', __FILE__)

module Bcdatabase::Commands
  describe Epass do
    before do
      enable_fake_cipherment
    end

    after do
      disable_fake_cipherment
    end

    describe 'interactive mode' do
      subject { Epass.new(false, :echo => true) }

      let(:output) {
        replace_stdin('zanzibar', 'chocolate') do
          capture_std do
            subject.run
          end
        end
      }

      it 'prompts the user' do
        output[:err].should =~ /Password \(\^C to end\):/
      end

      it 'outputs a YAML line for each password' do
        output[:out].split("\n").should == [
          '  epassword: rabiznaz',
          '  epassword: etalocohc'
        ]
      end

      it "doesn't echo the password" do
        pending "Don't know how to test this"
      end
    end

    describe 'streaming mode' do
      subject { Epass.new(true, :echo => true) }

      let(:output) {
        replace_stdin('abc', 'fed', 'beef') do
          capture_std do
            subject.run
          end[:out]
        end
      }

      it 'encrypts every line on standard in' do
        output.should == "cba\ndef\nfeeb\n"
      end
    end
  end
end
