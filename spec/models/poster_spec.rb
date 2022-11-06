describe Poster do
  describe 'relations' do
    it { is_expected.to belong_to(:anime).optional }
    it { is_expected.to belong_to(:manga).optional }
    it { is_expected.to belong_to(:character).optional }
    it { is_expected.to belong_to(:person).optional }
  end
end
