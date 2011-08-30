require File.expand_path('../../../spec_helper', __FILE__)

module Bcdatabase::Commands
  describe GenKey do
    let(:output) {
      capture_std do
        subject.run
      end
    }

    describe 'to standard out' do
      subject { GenKey.new(true) }

      it 'writes the key to standard out' do
        output[:out].size.should == 128
      end

      it 'writes nothing to stderr' do
        output[:err].should == ''
      end
    end

    describe 'to a file' do
      subject { GenKey.new(false) }

      let(:keydir)  { tmpdir }
      let(:keyfile) { keydir + 'key' }
      let(:read_opts) {
        if RUBY_VERSION > '1.9'
          { :encoding => 'ASCII-8BIT' }
        end
      }
      let(:keyfile_contents) { File.read(keyfile, read_opts) }

      before do
        ENV['BCDATABASE_PASS'] = keyfile.to_s
      end

      after do
        ENV['BCDATABASE_PASS'] = nil
      end

      it 'produces no output on STDOUT' do
        output[:out].should == ''
      end

      context 'when the directory does not exist' do
        let(:keydir) { tmpdir + 'var' }

        before do
          output
        end

        it 'creates the directory' do
          keydir.should be_readable
        end

        it 'creates the file' do
          keyfile_contents.size.should == 128
        end
      end

      context 'when the file does not exist' do
        it 'creates the file' do
          output
          keyfile_contents.size.should == 128
        end
      end

      context 'when the file exists' do
        before do
          keyfile.open('w') { }
        end

        it 'prompts to overwrite' do
          replace_stdin('yes') do
            output
          end[:err].should =~ /This operation will overwrite the existing pass file./
        end

        it 'overwrites if the user agrees' do
          replace_stdin('yes') do
            output
          end

          keyfile_contents.size.should == 128
        end

        it 'does not overwrite if the user backs out' do
          replace_stdin('no') do
            output
          end[:exception].should be_a ForcedExit

          keyfile_contents.size.should == 0
        end
      end
    end
  end
end
