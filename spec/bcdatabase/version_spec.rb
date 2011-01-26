require File.expand_path("../spec_helper", File.dirname(__FILE__))

require "bcdatabase/version"

describe Bcdatabase do
  it "should have a d.d.d version" do
    Bcdatabase::VERSION.should =~ /^\d+\.\d+\.\d+$/
  end
end
