describe OpenGraphView do
  include_context :seeds
  include_context :view_object_warden_stub

  let(:view) { described_class.new }

  describe '#site_name' do
    before { allow(view.h).to receive(:ru_host?).and_return is_ru_host }

    context 'ru_host' do
      let(:is_ru_host) { true }
      it { expect(view.site_name).to eq 'Шикимори' }
    end

    context 'not ru_host' do
      let(:is_ru_host) { false }
      it { expect(view.site_name).to eq 'Shikimori' }
    end
  end

  describe '#canonical_url' do
    context 'no page param' do
      before { allow(view.h.request).to receive(:url).and_return url }
      let(:url) { 'http://zzz.com?123#45' }
      it { expect(view.canonical_url).to eq 'http://zzz.com' }
    end

    context 'page param' do
      before do
        allow(view.h).to receive(:params).and_return params
        allow(view.h).to receive(:current_url) { |hash| view.h.url_for(params.merge(hash)) }
      end

      let(:params) do
        {
          controller: 'animes_collection',
          action: 'index',
          page: 2,
          klass: 'anime'
        }
      end
      it { expect(view.canonical_url).to eq '/animes' }
    end
  end
end
