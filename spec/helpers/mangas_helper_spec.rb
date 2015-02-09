
describe MangasHelper, :type => :helper do

  it "truncate_publisher" do
    expect(truncate_publisher("test test")).to eq("test test")
    expect(truncate_publisher("test test test test Comics")).to eq("test test test test")
    expect(truncate_publisher("test test test test Magazine")).to eq("test test test test")
    expect(truncate_publisher("test test test test Collection")).to eq("test test test test")
    expect(truncate_publisher("test test test test Collection")).to eq("test test test test")
    expect(truncate_publisher("test test test test ZXC")).to eq("test test test test ZXC")
  end
end
