describe Vote do
  describe 'relations' do
    it { should belong_to :user }
    it { should belong_to :voteable }
  end
end
