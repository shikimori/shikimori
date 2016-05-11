describe AnimesCollection::View do
  let(:view) { AnimesCollection::View.new klass }

  include_context :view_object_warden_stub

  let(:klass) { Anime }
  let(:user) { seed :user }
  let(:params) {{ controller: 'animes_collection' }}

  before { allow(view.h).to receive(:params).and_return params }

  describe '#collection' do
    let(:collection) { view.collection }

    context 'season page' do
      let!(:anime_1) { create :anime, :tv, aired_on: Date.parse('10-10-2016') }
      let(:params) {{ controller: 'animes_collection', season: 'fall_2016' }}
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
        allow(AnimesCollection::RecommendationsQuery)
          .to receive(:new).with(klass, params).and_return recommendations_query
        allow(AnimesCollection::SeasonQuery)
          .to receive(:new).with(klass, params).and_return season_query
        allow(AnimesCollection::PageQuery)
          .to receive(:new).with(klass, params).and_return page_query
      end

      let(:page) { AnimesCollection::Page.new collection: [] }
      let(:recommendations_query) { double fetch: page }
      let(:season_query) { double fetch: page }
      let(:page_query) { double fetch: page }

      subject { view.collection }

      context 'recommendations' do
        before { allow(view).to receive(:recommendations?).and_return true }
        it do
          is_expected.to be_empty
          expect(recommendations_query).to have_received :fetch
          expect(season_query).to_not have_received :fetch
          expect(page_query).to_not have_received :fetch
        end
      end

      context 'season' do
        before { allow(view).to receive(:season_page?).and_return true }
        it do
          is_expected.to be_empty
          expect(recommendations_query).to_not have_received :fetch
          expect(season_query).to have_received :fetch
          expect(page_query).to_not have_received :fetch
        end
      end

      context 'common query' do
        it do
          is_expected.to be_empty
          expect(recommendations_query).to_not have_received :fetch
          expect(season_query).to_not have_received :fetch
          expect(page_query).to have_received :fetch
        end
      end
    end
  end

  describe '#season_page?' do
    subject { view.season_page? }
    let(:params) do
      { season: season, controller: controller_name }
    end

    let(:season) { 'fall_2016' }
    let(:controller_name) { 'animes_collection' }

    context 'not matched season' do
      let(:season) { '2016' }
      it { is_expected.to eq false }
    end

    context 'no season' do
      let(:season) { }
      it { is_expected.to eq false }
    end

    context 'recommendations contoller' do
      let(:controller_name) { 'recommendations' }
      it { is_expected.to eq false }
    end
  end

  describe '#recommendations?' do
    subject { view.recommendations? }
    let(:params) {{ controller: controller_name }}

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
    let(:params) {{ controller: controller_name }}

    context 'recommendations controller' do
      let(:controller_name) { 'recommendations' }
      it { is_expected.to eq false }
    end

    context 'animes_collection controller' do
      let(:controller_name) { 'animes_collection' }
      it { is_expected.to eq true }
    end
  end

  describe '#cache_key & #cache?' do
    subject { view.cache_key }
    let(:params) do
      {
        controller: 'test',
        format: 'json',
        action: 'index',
        page: '1',
        status: 'ongoing'
      }
    end
    it { is_expected.to eq %w(Anime page:1 status:ongoing) }
  end

  describe '#cache_expires_in' do
    subject { view.cache_expires_in }

    context 'no season, no status params' do
      let(:params) {{ page: '1' }}
      it { is_expected.to eq 1.week }
    end

    context 'season param' do
      let(:params) {{ season: '1' }}
      it { is_expected.to eq 1.day }
    end

    context 'status param' do
      let(:params) {{ status: '1' }}
      it { is_expected.to eq 1.day }
    end
  end

  describe '#url' do
    let(:params) do
      {
        controller: 'animes_collection',
        klass: 'anime',
        format: 'a',
        page: '2'
      }
    end

    it { expect(view.url type: 'tv').to eq  '/animes/type/tv/page/2' }
  end

  describe 'url params' do
    let(:params) do
      {
        controller: 'animes_collection',
        klass: 'anime',
        format: 'a',
        template: 'd',
        is_adult: 'e',
        type: 'tv',
        AnimesCollection::RecommendationsQuery::IDS_KEY => ['c'],
        AnimesCollection::RecommendationsQuery::EXCLUDE_IDS_KEY => ['b']
      }
    end

    describe '#prev_page_url' do
      before { allow(view).to receive(:page).and_return page }
      before { allow(view).to receive(:pages_count).and_return pages_count }

      let(:pages_count) { 2 }

      subject { view.prev_page_url }

      context 'first page' do
        let(:page) { 1 }
        it { is_expected.to be_nil }
      end

      context 'second page' do
        let(:page) { 2 }
        it { is_expected.to eq '/animes/type/tv/page/1' }
      end
    end

    describe '#next_page_url' do
      before { allow(view).to receive(:page).and_return page }
      before { allow(view).to receive(:pages_count).and_return pages_count }

      let(:pages_count) { 2 }

      subject { view.next_page_url }

      context 'first page' do
        let(:page) { 1 }
        it { is_expected.to eq '/animes/type/tv/page/2' }
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

    describe '#filtered_params' do
      subject { view.filtered_params }
      it do
        is_expected.to eq(
          controller: 'animes_collection',
          klass: 'anime',
          type: 'tv'
        )
      end
    end
  end
end
