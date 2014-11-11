
describe EntryView, :type => :model do
  it { should belong_to :user }
  it { should belong_to :entry }
end
