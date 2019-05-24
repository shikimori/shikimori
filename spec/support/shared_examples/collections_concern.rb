shared_examples :collections_concern do
  describe 'collections concern' do
    describe 'associations' do
      it { is_expected.to have_many(:collection_links).dependent :destroy }
      it { is_expected.to have_many :collections }
    end
  end
end
