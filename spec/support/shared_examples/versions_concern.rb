shared_examples :versions_concern do
  describe 'versions concern' do
    describe 'associations' do
      it { is_expected.to have_many(:versions).dependent :destroy }
    end
  end
end
