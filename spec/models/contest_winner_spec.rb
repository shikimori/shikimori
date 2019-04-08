describe ContestWinner do
  describe 'relations' do
    it { is_expected.to belong_to :contest }
    it { is_expected.to belong_to :item }
    it { is_expected.to belong_to(:anime).optional }
    it { is_expected.to belong_to(:character).optional }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :contest }
    it { is_expected.to validate_presence_of :item }
    it { is_expected.to validate_presence_of :position }
    it { is_expected.to validate_numericality_of(:position).is_greater_than 0 }
  end
end
