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
      it { expect(view.canonical_url).to be_html_safe }
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
      it { expect(view.canonical_url).to be_html_safe }
    end
  end

  describe '#page_title, #meta_title, #headline' do
    context 'has title' do
      before do
        view.page_title = 'test'
        view.page_title = '123'
      end

      it { expect(view.meta_title).to eq '<title>123 / test</title>' }
      it { expect(view.meta_title).to be_html_safe }
      it { expect(view.headline).to eq '123' }
    end

    context 'no title' do
      before { allow(view.h).to receive(:ru_host?).and_return is_ru_host }
      let(:is_ru_host) { true }

      context 'ru_host' do
        it { expect(view.meta_title).to eq '<title>Шикимори</title>' }
      end

      context 'not ru_host' do
        let(:is_ru_host) { false }
        it { expect(view.meta_title).to eq '<title>Shikimori</title>' }
      end

      it { expect { view.headline }.to raise_error 'open_graph.page_title is not set' }
      it { expect { view.headline false }.to raise_error 'open_graph.page_title is not set' }
      it { expect(view.headline true).to eq view.site_name }
    end

    context 'development' do
      before do
        view.page_title = 'test'
        view.page_title = '123'
        allow(Rails.env).to receive(:development?).and_return true
      end

      it { expect(view.meta_title).to eq '<title>[DEV] 123 / test</title>' }
    end
  end

  describe '#notice, #description' do
    before do
      view.notice = notice
      view.description = description
    end
    let(:notice) { '123' }
    let(:description) { '456' }

    it { expect(view.notice).to eq notice }
    it { expect(view.description).to eq description }

    context 'no notice' do
      let(:notice) { nil }
      it { expect(view.notice).to eq description }
      it { expect(view.description).to eq description }
    end

    context 'no description' do
      let(:description) { nil }
      it { expect(view.notice).to eq notice }
      it { expect(view.description).to eq notice }
    end
  end
end
