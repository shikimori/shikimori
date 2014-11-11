describe Vote do
  context :relations do
    it { should belong_to :user }
    it { should belong_to :voteable }
  end
end
