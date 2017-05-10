describe CollectionsQuery do
  let(:query) { CollectionsQuery.new :ru }

  include_context :timecop

  let!(:collection_1) { create :collection, :published, id: 1 }
  let!(:collection_2) { create :collection, :published, id: 2 }
  let!(:collection_3) { create :collection, :published, id: 3 }
  let!(:collection_en) { create :collection, :published, id: 5, locale: :en }
  let!(:collection_en) { create :collection, :unpublished, id: 6 }

  describe '#fetch' do
    subject { query.fetch page, limit }

    let(:with_favourites) { false }
    let(:limit) { 2 }

    context 'first_page' do
      let(:page) { 1 }
      it { is_expected.to eq [collection_1, collection_2, collection_3] }
    end

    context 'second_page' do
      let(:page) { 2 }
      it { is_expected.to eq [collection_3] }
    end
  end

  describe '#postload' do
    subject { query.postload page, limit }
    let(:limit) { 2 }

    context 'first_page' do
      let(:page) { 1 }
      it { is_expected.to eq [[collection_1, collection_2], true] }
    end

    context 'second_page' do
      let(:page) { 2 }
      it { is_expected.to eq [[collection_3], false] }
    end
  end
end
