describe TransformedCollection do
  subject(:mapping) do
    described_class.new collection, transformation, action
  end
  let(:collection) { PaginatedCollection.new([1, 2], 1, 2) }
  let(:transformation) { :map }
  let(:action) { ->(value) { value * 2 } }

  describe 'collection' do
    context 'map' do
      it { is_expected.to eq [2, 4] }
    end

    context 'filter' do
      let(:transformation) { :filter }
      let(:action) { ->(value) { value == 1 } }
      it { is_expected.to eq [1] }
    end
  end

  describe 'respond_to original collection methods' do
    its(:page) { is_expected.to eq 1 }
  end
end
