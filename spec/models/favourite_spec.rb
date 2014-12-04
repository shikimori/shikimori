describe Favourite do
  describe 'relations' do
    it { should belong_to :linked }
    it { should belong_to :user }
  end
end
