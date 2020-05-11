describe ClubLink do
  describe 'relations' do
    it { is_expected.to belong_to :club }
    it { is_expected.to belong_to :linked }
  end

  describe 'validations' do
    it { is_expected.to validate_uniqueness_of(:club_id).scoped_to(:linked_id, :linked_type) }
  end
end
