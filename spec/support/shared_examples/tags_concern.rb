shared_examples :tags_concern do
  describe 'tags concern' do
    before { subject.tags = tags }
    let(:tags) { %w[#Аниме test] }
    its(:tags) { is_expected.to eq %w[аниме test] }
  end
end
