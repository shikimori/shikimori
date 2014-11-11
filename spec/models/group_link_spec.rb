describe GroupLink, :type => :model do
  context '#relations' do
    it { should belong_to :group }
    it { should belong_to :linked }
  end
end
