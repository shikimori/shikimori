describe Forums::View do
  include_context :seeds
  include_context :view_object_warden_stub

  let(:view) { Forums::View.new }
  let(:params) {{ }}

  before { allow(view.h).to receive(:params).and_return params }

  describe '#forum' do
    context 'offtopic' do
      let(:params) {{ forum: 'offtopic' }}
      it do
        expect(view.forum).to have_attributes(
          permalink: 'offtopic'
        )
      end
    end

    context 'all' do
      it { expect(view.forum).to be_nil }
    end
  end

  describe '#topics' do
    before { user.preferences.forums = [offtopic_forum.id] }
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
      let(:params) {{ forum: 'all', linked_type: 'xx', linked_id: 'zz' }}
      before { allow(view).to receive(:add_postloader?).and_return true }

      it do
        expect(view.next_page_url).to eq 'http://test.host/forum/xx-zz/p-2'
        expect(view.prev_page_url).to be_nil
      end
    end

    context 'second page' do
      let(:params) {{ forum: 'all', page: 2 }}
      it do
        expect(view.next_page_url).to be_nil
        expect(view.prev_page_url).to eq 'http://test.host/forum/p-1'
      end
    end
  end

  describe '#faye_subscriptions' do
    before { user.preferences.forums = [offtopic_forum.id] }
    it { expect(view.faye_subscriptions).to eq ["forum-#{offtopic_forum.id}"] }
  end

  describe '#menu' do
    it { expect(view.menu).to be_kind_of Forums::Menu }
  end

  describe '#linked' do
    before { allow(view).to receive_message_chain(:forum, :permalink)
      .and_return permalink }
    let(:params) {{ linked_type: entry.class.name.downcase, linked_id: entry.id }}

    context 'a' do
      let(:permalink) { 'a' }
      let(:entry) { create :anime }

      it { expect(view.linked).to eq entry }
    end

    context 'm' do
      let(:permalink) { 'm' }
      let(:entry) { create :manga }

      it { expect(view.linked).to eq entry }
    end

    context 'c' do
      let(:permalink) { 'c' }
      let(:entry) { create :character }

      it { expect(view.linked).to eq entry }
    end

    context 'g' do
      let(:permalink) { 'g' }
      let(:entry) { create :group }

      it { expect(view.linked).to eq entry }
    end

    context 'reviews' do
      let(:permalink) { 'reviews' }
      let(:entry) { create :review }

      it { expect(view.linked).to eq entry }
    end

    context 'other' do
      let(:params) {{ linked: 'zzz' }}
      let(:permalink) { 'other' }

      it { expect(view.linked).to be_nil }
    end

    context 'no linekd' do
      let(:params) {{ }}
      let(:permalink) { }

      it { expect(view.linked).to be_nil }
    end
  end
end
