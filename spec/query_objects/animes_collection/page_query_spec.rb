describe AnimesCollection::PageQuery do
  let(:query) do
    AnimesCollection::PageQuery.new(
      klass: klass,
      filters: filters,
      user: nil,
      limit: 20
    )
  end

  subject(:page) { query.call }

  let!(:anime_1) { create :anime, :tv, ranked: 1 }
  let!(:anime_2) { create :anime, :ova, ranked: 2 }
  let!(:manga) { create :manga, ranked: 1 }
  let!(:ranobe) { create :ranobe, ranked: 2 }

  let(:filters) { { kind: kind } }
  let(:kind) { nil }

  context 'anime' do
    let(:klass) { Anime }

    context 'pagination' do
      before { allow(query).to receive(:limit).and_return 1 }

      it do
        is_expected.to have_attributes(
          collection: [anime_1],
          page: 1,
          pages_count: 2
        )
      end
    end

    context 'without kind' do
      it do
        is_expected.to have_attributes(
          collection: [anime_1, anime_2],
          page: 1,
          pages_count: 1
        )
      end
    end

    context 'with kind' do
      let(:kind) { 'tv' }
      it do
        is_expected.to have_attributes(
          collection: [anime_1],
          page: 1,
          pages_count: 1
        )
      end
    end
  end

  context 'manga' do
    let(:klass) { Manga }

    it do
      is_expected.to have_attributes(
        collection: [manga],
        page: 1,
        pages_count: 1
      )
    end
  end

  context 'ranobe' do
    let(:klass) { Ranobe }

    it do
      is_expected.to have_attributes(
        collection: [ranobe],
        page: 1,
        pages_count: 1
      )
    end
  end
end
