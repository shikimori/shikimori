describe PaginatedCollection do
  subject(:pagination) { PaginatedCollection.new collection, page, total_pages }

  let(:collection) { [1,2] }
  let(:page) { 1 }
  let(:total_pages) { 15 }

  it { is_expected.to eq collection }

  describe '#next_page' do
    subject { pagination.next_page }

    context 'last page' do
      let(:page) { 15 }
      it { is_expected.to be_nil }
    end

    context 'not first page' do
      let(:page) { 10 }
      it { is_expected.to eq 11 }
    end
  end

  describe '#prev_page' do
    subject { pagination.prev_page }

    context 'first page' do
      let(:page) { 1 }
      it { is_expected.to be_nil }
    end

    context 'not first page' do
      let(:page) { 10 }
      it { is_expected.to eq 9 }
    end
  end
end
