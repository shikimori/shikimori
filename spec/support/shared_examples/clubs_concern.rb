shared_examples :clubs_concern do |type|
  describe 'clubs concern' do
    describe 'associations' do
      it { is_expected.to have_many(:club_links).dependent :destroy }
      it { is_expected.to have_many :clubs }
    end
  end
end
