describe ClubLink do
  describe 'relations' do
    it { is_expected.to belong_to :club }
    it { is_expected.to belong_to :linked }
  end

  describe 'validations' do
    it { is_expected.to validate_uniqueness_of(:club_id).scoped_to(:linked_id, :linked_type) }
  end

  describe 'callbacks' do
    describe '#ensure_ranobe_linked_type' do
      let(:club_link) { create :club_link, club: club, linked: manga }
      let(:club) { create :club }
      let(:manga) { create :ranobe }
      it { expect(club_link.linked_type).to eq Ranobe.name }
    end
  end
end
