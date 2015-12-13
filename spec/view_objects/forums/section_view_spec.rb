describe Forums::SectionView do
  include_context :view_object_warden_stub

  let(:view) { Forums::SectionView.new }
  let(:user) { seed :user }
  let(:params) {{ }}

  before { allow(view.h).to receive(:params).and_return params }

  describe '#section' do
    it do
      expect(view.section).to have_attributes(
        id: nil,
        permalink: 'all'
      )
    end
  end

  describe '#topics' do
    it do
      expect(view.topics).to have(1).item
      expect(view.topics.first).to be_kind_of Topics::View
    end
  end

  describe '#page' do
    context 'has page in params' do
      let(:params) {{ page: 2 }}
      it { expect(view.page).to eq 2 }
    end

    context 'no page in params' do
      it { expect(view.page).to eq 1 }
    end
  end

  describe '#limit' do
    context 'no format' do
      it { expect(view.limit).to eq 8 }
    end

    context 'rss format' do
      let(:params) {{ format: 'rss' }}
      it { expect(view.limit).to eq 30 }
    end
  end

  describe '#next_page_url & #prev_page_url' do
    context 'first page' do
      let(:params) {{ section: 'all', linked: 'zz' }}
      before { allow(view).to receive(:add_postloader?).and_return true }

      it do
        expect(view.next_page_url).to eq 'http://test.host/forum/all/s-zz/p-2'
        expect(view.prev_page_url).to be_nil
      end
    end

    context 'second page' do
      let(:params) {{ section: 'all', page: 2 }}
      it do
        expect(view.next_page_url).to be_nil
        expect(view.prev_page_url).to eq 'http://test.host/forum/all/p-1'
      end
    end
  end

  describe '#faye_subscriptions' do
    it { expect(view.faye_subscriptions)
      .to eq Section.real.map { |v| "section-#{v.id}" } }
  end
end
