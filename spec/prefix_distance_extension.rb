require 'modules/prefix_distance_extension'

describe PrefixDistanceExtension do
  before( :all ) do
    String.send( 'include', PrefixDistanceExtension )
  end

  context "(in general)" do
    it "should return nil if string to is nil" do
      ("abc".bin_dist_to nil).should == nil
    end
    it "should return 0 for strings that are complete equal" do
      ("abc".bin_dist_to "abc").should == 0
    end
    it "should return length of string, if complete different" do
      ("abc".bin_dist_to "def").should == 3
    end
    it "should return position +1 from the end of the string, where the difference is" do
      ("abcdef".bin_dist_to "abddef").should == 4
    end
    it "should return length of the smaller string" do
      ("abc".bin_dist_to "abcdef").should == 3
    end
  end
end
