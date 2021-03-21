describe AnimesCollection::View do
  let(:view) { AnimesCollection::View.new klass, user }
  let(:user) { user }

  include_context :view_context_stub

  let(:klass) { Anime }
  let(:user) { seed :user }
  let(:view_context_params) do
    {
      controller: 'animes_collection',
      action: 'index'
    }
  end

  before do
    allow(view.h).to receive(:safe_params).and_return view_context_params
    allow(view.h).to receive(:url_params).and_return view_context_params
    allow(view).to receive(:search_russian?).and_return nil
  end

  describe '#collection' do
    let(:collection) { view.collection }

    context 'season page' do
      let!(:anime_1) { create :anime, :tv, aired_on: Date.parse('10-10-2016') }
      let(:view_context_params) do
        {
          controller: 'animes_collection',
          season: 'fall_2016'
        }
      end

      it do
        expect(collection).to have(1).item
        expect(collection['tv']).to have(1).item
        expect(collection['tv'].first).to be_kind_of AnimeDecorator
        expect(collection['tv'].first.object).to eq anime_1
      end
    end

    context 'common page' do
      let!(:anime_1) { create :anime, :tv, aired_on: Date.parse('10-10-2016') }
      it do
        expect(collection).to have(1).item
        expect(collection.first).to be_kind_of AnimeDecorator
        expect(collection.first.object).to eq anime_1
      end
    end

    describe 'query method' do
      before do
        allow(Recommendations::Fetcher)
          .to receive(:call)
          .with(
            user: user,
            klass: klass,
            metric: metric,
            threshold: threshold.to_i
          )
          .and_return ranked_ids
        allow(AnimesCollection::RecommendationsQuery)
          .to receive(:call)
          .with(
            klass: klass,
            filters: view.compiled_filters,
            user: user,
            limit: AnimesCollection::View::PAGE_LIMIT,
            ranked_ids: ranked_ids
          ).and_return page

        allow(AnimesCollection::SeasonQuery)
          .to receive(:call)
          .with(
            klass: klass,
            filters: view.compiled_filters,
            user: user,
            limit: AnimesCollection::View::SEASON_LIMIT
          ).and_return page

        allow(AnimesCollection::PageQuery)
          .to receive(:call)
          .with(
            klass: klass,
            filters: view.compiled_filters,
            user: user,
            limit: AnimesCollection::View::PAGE_LIMIT
          ).and_return page
      end
      let(:threshold) { '5000' }
      let(:metric) { 'pearson_z' }
      let(:ranked_ids) { ['zzz'] }

      let(:page) do
        AnimesCollection::Page.new(
          collection: [],
          page: 1,
          pages_count: 0
        )
      end

      subject { view.collection }

      context 'recommendations' do
        let(:view_context_params) do
          {
            controller: 'recommendations',
            action: 'index',
            threshold: threshold,
            metric: metric
          }
        end

        context 'has ranked_ids' do
          it do
            is_expected.to eq []
            expect(AnimesCollection::RecommendationsQuery).to have_received :call
            expect(AnimesCollection::SeasonQuery).to_not have_received :call
            expect(AnimesCollection::PageQuery).to_not have_received :call
          end
        end

        context 'empty ranked_ids' do
          let(:ranked_ids) { [] }
          it do
            is_expected.to eq []
            expect(AnimesCollection::RecommendationsQuery).to have_received :call
            expect(AnimesCollection::SeasonQuery).to_not have_received :call
            expect(AnimesCollection::PageQuery).to_not have_received :call
          end
        end

        context 'no ranked_ids' do
          let(:ranked_ids) { nil }
          it do
            is_expected.to be_nil
            expect(AnimesCollection::RecommendationsQuery).to_not have_received :call
            expect(AnimesCollection::SeasonQuery).to_not have_received :call
            expect(AnimesCollection::PageQuery).to_not have_received :call
          end
        end
      end

      context 'season' do
        before { allow(view).to receive(:season_page?).and_return true }
        it do
          is_expected.to be_empty
          expect(AnimesCollection::RecommendationsQuery).to_not have_received :call
          expect(AnimesCollection::SeasonQuery).to have_received :call
          expect(AnimesCollection::PageQuery).to_not have_received :call
        end
      end

      context 'common query' do
        it do
          is_expected.to be_empty
          expect(AnimesCollection::RecommendationsQuery).to_not have_received :call
          expect(AnimesCollection::SeasonQuery).to_not have_received :call
          expect(AnimesCollection::PageQuery).to have_received :call
        end
      end
    end
  end

  describe '#season_page?' do
    subject { view.season_page? }
    let(:view_context_params) do
      {
        controller: controller_name,
        season: season
      }
    end

    let(:season) { 'fall_2016' }
    let(:controller_name) { 'animes_collection' }

    context 'not matched season' do
      let(:season) { '2016' }
      it { is_expected.to eq false }
    end

    context 'no season' do
      let(:season) { nil }
      it { is_expected.to eq false }
    end

    context 'recommendations contoller' do
      let(:controller_name) { 'recommendations' }
      it { is_expected.to eq false }
    end
  end

  describe '#recommendations?' do
    subject { view.recommendations? }
    let(:view_context_params) { { controller: controller_name } }

    context 'recommendations controller' do
      let(:controller_name) { 'recommendations' }
      it { is_expected.to eq true }
    end

    context 'animes_collection controller' do
      let(:controller_name) { 'animes_collection' }
      it { is_expected.to eq false }
    end
  end

  describe '#cache?' do
    subject { view.cache? }
    let(:view_context_params) { { controller: controller_name } }

    context 'recommendations controller' do
      let(:controller_name) { 'recommendations' }
      it { is_expected.to eq false }
    end

    context 'animes_controller' do
      let(:controller_name) { 'animes_collection' }
      it { is_expected.to eq true }
    end
  end

  describe '#cache_key & #cache?' do
    subject { view.cache_key }
    let(:view_context_params) do
      {
        controller: 'test',
        format: 'json',
        action: 'index',
        page: '1',
        status: 'ongoing'
      }
    end

    it do
      is_expected.to eq(
        %W[Anime #{AnimesCollection::View::CACHE_VERSION} page:1 status:ongoing]
      )
    end
  end

  describe '#cache_expires_in' do
    subject { view.cache_expires_in }

    context 'no season, no status params' do
      let(:view_context_params) { { page: '1' } }
      it { is_expected.to eq 3.days }
    end

    context 'season param' do
      let(:view_context_params) { { season: '1' } }
      it { is_expected.to eq 1.day }
    end

    context 'status param' do
      let(:view_context_params) { { status: '1' } }
      it { is_expected.to eq 1.day }
    end
  end

  describe 'pagination urls' do
    let(:view_context_params) do
      {
        controller: 'animes_collection',
        action: 'index',
        kind: 'tv',
        status: nil,
        season: nil,
        franchise: nil,
        achievement: nil,
        genre: nil,
        studio: nil,
        publisher: nil,
        duration: nil,
        rating: nil,
        score: nil,
        options: nil,
        mylist: nil,
        'order-by': nil,
        page: nil
      }
    end

    describe '#prev_page_url' do
      before do
        allow(view).to receive(:page).and_return page
        allow(view).to receive(:pages_count).and_return pages_count
        allow(view.h).to receive(:current_url) do |v|
          view.h.animes_collection_url view_context_params.merge(v)
        end
      end

      let(:pages_count) { 3 }

      subject { view.prev_page_url }

      context 'first page' do
        let(:page) { 1 }
        it { is_expected.to be_nil }
      end

      context 'second page' do
        let(:page) { 2 }
        it { is_expected.to eq "#{Shikimori::PROTOCOL}://test.host/animes/kind/tv" }
      end

      context 'third page' do
        let(:page) { 3 }
        it { is_expected.to eq "#{Shikimori::PROTOCOL}://test.host/animes/kind/tv/page/2" }
      end
    end

    describe '#next_page_url' do
      before do
        allow(view).to receive(:page).and_return page
        allow(view).to receive(:pages_count).and_return pages_count
        allow(view.h).to receive(:current_url) do |v|
          view.h.animes_collection_url view_context_params.merge(v)
        end
      end

      let(:pages_count) { 2 }

      subject { view.next_page_url }

      context 'first page' do
        let(:page) { 1 }
        it do
          is_expected.to eq "#{Shikimori::PROTOCOL}://test.host/animes/kind/tv/page/2"
        end
      end

      context 'second page' do
        let(:page) { 2 }
        it { is_expected.to be_nil }
      end

      context 'only one page' do
        let(:page) { 1 }
        let(:pages_count) { 1 }
        it { is_expected.to be_nil }
      end
    end
  end

  describe '#compiled_filters' do
    it do
      expect(view.compiled_filters).to eq view_context_params.merge(
        censored: true,
        order: :ranked
      )
    end
  end
end
