describe AnimesCollection::View do
  let(:view) { AnimesCollection::View.new }

  include_context :view_object_warden_stub

  let(:user) { seed :user }
  let(:params) {{ controller: 'animes_collection' }}

  before { allow(view.h).to receive(:params).and_return params }

  describe '#collection' do
    let!(:anime_1) { create :anime, :tv }
    let(:collection) { view.collection }
    it do
      expect(collection).to have(1).item
      expect(collection.first).to be_kind_of AnimeDecorator
      expect(collection.first.object).to eq anime_1
    end
  end

  describe '#group' do
    let!(:anime_1) { create :anime, :tv, aired_on: Date.parse('10-10-2016') }
    let(:params) {{ controller: 'animes_collection', season: 'fall_2016' }}
    subject(:groups) { view.groups }
    it do
      expect(groups).to have(1).item
      expect(groups['tv']).to have(1).item
      expect(groups['tv'].first).to be_kind_of AnimeDecorator
      expect(groups['tv'].first.object).to eq anime_1
    end
  end

  describe '#season_page?' do
    subject { view.season_page? }
    let(:params) do
      { season: season, ids_with_sort: ids_with_sort, controller: controller_name }
    end

    let(:season) { 'fall_2016' }
    let(:ids_with_sort) { }
    let(:controller_name) { 'animes_collection' }

    context 'ids_with_sort' do
      let(:ids_with_sort) { [1] }
      it { is_expected.to eq false }
    end

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
    it { is_expected.to eq %w(animes_collection page:1 status:ongoing) }
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
        format: 'a',
        exclude_ids: ['b'],
        ids_with_sort: ['c'],
        template: 'd',
        is_adult: 'e',
        exclude_ai_genres: ['f'],
        type: 'tv'
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
      it { is_expected.to eq controller: 'animes_collection', type: 'tv' }
    end
  end

  describe '#klass' do
    context 'recommendations' do
      let(:params) {{ controller: 'recommendations' }}
      it { expect{view.klass}.to raise_error ArgumentError }
    end

    context 'animes_collection' do
      let(:params) {{ controller: 'animes_collection' }}
      it { expect(view.klass).to eq Anime }
    end

    context 'mangas_collection' do
      let(:params) {{ controller: 'mangas_collection' }}
      it { expect(view.klass).to eq Manga }
    end
  end
end
