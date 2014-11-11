
describe RelatedManga, :type => :model do
  it { should belong_to :source }
  it { should belong_to :anime }
  it { should belong_to :manga }
end
