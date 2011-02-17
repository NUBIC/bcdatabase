require File.expand_path("../spec_helper", File.dirname(__FILE__))

require "bcdatabase/version"

describe Bcdatabase do
  it "should have a d.d.d or d.d.d.text version" do
    Bcdatabase::VERSION.should =~ /^\d+\.\d+\.\d+(\.\S+)?$/
  end
end
