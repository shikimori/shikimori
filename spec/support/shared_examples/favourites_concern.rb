shared_examples :favourites_concern do
  describe 'favourites concern' do
    describe 'associations' do
      it { is_expected.to have_many(:favourites).dependent :destroy }
    end
  end
end
