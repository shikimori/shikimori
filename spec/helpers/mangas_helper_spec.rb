
describe MangasHelper do

  it "truncate_publisher" do
    truncate_publisher("test test").should == "test test"
    truncate_publisher("test test test test Comics").should == "test test test test"
    truncate_publisher("test test test test Magazine").should == "test test test test"
    truncate_publisher("test test test test Collection").should == "test test test test"
    truncate_publisher("test test test test Collection").should == "test test test test"
    truncate_publisher("test test test test ZXC").should == "test test test test ZXC"
  end
end
