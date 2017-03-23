describe AnimesCollection::RecommendationsQuery do
  let(:query) do
    AnimesCollection::RecommendationsQuery.new(
      klass: Anime,
      params: params,
      user: nil,
      limit: 20
    )
  end
  let(:params) do
    {
      AniMangaQuery::IDS_KEY => [
        anime_4.id,
        anime_2.id,
        anime_3.id
      ],
      AniMangaQuery::EXCLUDE_IDS_KEY => exclude_ids
    }
  end
  let(:exclude_ids) { [] }

  describe '#fetch' do
    subject(:page) { query.call }

    let!(:anime_1) { create :anime, ranked: 1 }
    let!(:anime_2) { create :anime, ranked: 2 }
    let!(:anime_3) { create :anime, ranked: 3 }
    let!(:anime_4) { create :anime, ranked: 4 }

    it do
      is_expected.to have_attributes(
        collection: [anime_4, anime_2, anime_3],
        page: 1,
        pages_count: 1
      )
    end

    context 'pagination' do
      before { allow(query).to receive(:limit).and_return 2 }
      it do
        is_expected.to have_attributes(
          collection: [anime_4, anime_2],
          page: 1,
          pages_count: 2
        )
      end
    end

    context 'exclude_ids' do
      let(:exclude_ids) { [anime_3.id] }

      it do
        is_expected.to have_attributes(
          collection: [anime_4, anime_2],
          page: 1,
          pages_count: 1
        )
      end
    end
  end
end
