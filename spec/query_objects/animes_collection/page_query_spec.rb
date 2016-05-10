describe AnimesCollection::PageQuery do
  let(:query) { AnimesCollection::PageQuery.new params, klass }

  describe '#fetch' do
    subject(:page) { query.fetch }
    let!(:anime_1) { create :anime, :tv, ranked: 1 }
    let!(:anime_2) { create :anime, :ova, ranked: 2 }
    let!(:manga) { create :manga }

    let(:params) {{ type: type }}
    let(:type) { }

    context 'anime' do
      let(:klass) { Anime }

      context 'without type' do
        it do
          is_expected.to have_attributes(
            collection: [anime_1, anime_2],
            page: 1,
            pages_count: 1
          )
        end
      end

      context 'with type' do
        let(:type) { 'tv' }
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
  end
end
