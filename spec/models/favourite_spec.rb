describe Favourite do
  describe 'relations' do
    it { is_expected.to belong_to :linked }
    it { is_expected.to belong_to :user }
  end
end
