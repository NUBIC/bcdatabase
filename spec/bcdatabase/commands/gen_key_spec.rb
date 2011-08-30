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

      let(:keydir)  { tmpdir + 'var' }
      let(:keyfile) { keydir + 'key' }

      before do
        ENV['BCDATABASE_PASS'] = keyfile.to_s
        keydir.mkpath
      end

      after do
        ENV['BCDATABASE_PASS'] = nil
      end

      it 'produces no output on STDOUT' do
        output[:out].should == ''
      end

      context 'when the file does not exist' do
        it 'creates the file' do
          output
          File.read(keyfile).size.should == 128
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

          File.read(keyfile).size.should == 128
        end

        it 'does not overwrite if the user backs out' do
          begin
            replace_stdin('no') do
              output
            end
            fail "Exception not thrown"
          rescue ForcedExit => e
            e.code.should == 1
          end

          File.read(keyfile).size.should == 0
        end
      end
    end
  end
end
