describe PersonRole, :type => :model do
  it { should belong_to :anime }
  it { should belong_to :manga }
  it { should belong_to :character }
  it { should belong_to :person }
end
