describe PaginatedCollection do
  subject(:pagination) { PaginatedCollection.new collection, page, limit }

  let(:collection) { [1, 2] }
  let(:page) { 1 }
  let(:limit) { 2 }

  it { is_expected.to eq collection }

  describe '#next_page' do
    subject { pagination.next_page }

    context 'collection.size != limit' do
      let(:limit) { 3 }
      it { is_expected.to be_nil }
    end

    context 'collection.size == limit' do
      let(:limit) { 2 }
      it { is_expected.to eq 2 }
    end
  end

  describe '#next_page?' do
    subject { pagination.next_page? }

    context 'collection.size != limit' do
      let(:limit) { 3 }
      it { is_expected.to eq false }
    end

    context 'collection.size == limit' do
      let(:limit) { 2 }
      it { is_expected.to eq true }
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

  describe '#prev_page?' do
    subject { pagination.prev_page? }

    context 'first page' do
      let(:page) { 1 }
      it { is_expected.to eq false }
    end

    context 'not first page' do
      let(:page) { 10 }
      it { is_expected.to eq true }
    end
  end
end
