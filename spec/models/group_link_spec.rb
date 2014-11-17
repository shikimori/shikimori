describe GroupLink do
  describe 'relations' do
    it { should belong_to :group }
    it { should belong_to :linked }
  end
end
