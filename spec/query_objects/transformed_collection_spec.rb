describe TransformedCollection do
  subject(:mapping) do
    TransformedCollection.new collection do |value|
      value * 2
    end
  end
  let(:collection) { PaginatedCollection.new([1, 2], 1, 2) }

  describe 'collection' do
    it { is_expected.to eq [2, 4] }
  end

  describe 'respond_to original collection methods' do
    its(:page) { is_expected.to eq 1 }
  end
end
