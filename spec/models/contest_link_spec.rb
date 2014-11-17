describe ContestLink do
  describe 'relations' do
    it { should belong_to :contest }
    it { should belong_to :linked }
  end
end
