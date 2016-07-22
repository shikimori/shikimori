describe Forums::View do
  include_context :seeds
  include_context :view_object_warden_stub

  let(:view) { Forums::View.new }
  let(:params) { {} }

  before { allow(view.h).to receive(:params).and_return params }

  describe '#forum' do
    context 'offtopic' do
      let(:params) { { forum: 'offtopic' } }
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

  describe '#topic_views' do
    before { user.preferences.forums = [offtopic_forum.id] }

    it do
      expect(view.topic_views).to have(3).items
      expect(view.topic_views.first).to be_kind_of Topics::View
    end
  end

  describe '#page' do
    context 'has page in params' do
      let(:params) { { page: 2 } }
      it { expect(view.send :page).to eq 2 }
    end

    context 'no page in params' do
      it { expect(view.send :page).to eq 1 }
    end
  end

  describe '#limit' do
    context 'no format' do
      it { expect(view.send :limit).to eq 8 }
    end

    context 'rss format' do
      let(:params) { { format: 'rss' } }
      it { expect(view.send :limit).to eq 30 }
    end
  end

  describe '#next_page_url & #prev_page_url' do
    context 'first page' do
      let(:params) { { forum: 'all', linked_type: 'xx', linked_id: 'zz' } }
      before do
        allow(view).to receive(:topic_views).and_return double(
          next_page: 3,
          prev_page: nil
        )
      end

      it do
        expect(view.next_page_url).to eq '//test.host/forum/xx-zz/p-3'
        expect(view.prev_page_url).to be_nil
      end
    end

    context 'second page' do
      let(:params) { { forum: 'all', page: 2 } }
      it do
        expect(view.next_page_url).to be_nil
        expect(view.prev_page_url).to eq '//test.host/forum/p-1'
      end
    end
  end

  describe '#faye_subscriptions' do
    before { user.preferences.forums = [offtopic_forum.id] }
    it { expect(view.faye_subscriptions).to eq ["forum-#{offtopic_forum.id}/ru"] }
  end

  describe '#menu' do
    it { expect(view.menu).to be_kind_of Forums::Menu }
  end

  describe '#linked' do
    before do
      allow(view).to receive_message_chain(:forum, :permalink)
        .and_return permalink
    end
    let(:params) do
      {
        linked_type: entry.class.name.downcase,
        linked_id: entry.id
      }
    end

    context 'animanga' do
      let(:permalink) { 'animanga' }

      context 'anime' do
        let(:entry) { create :anime }
        it { expect(view.linked).to eq entry }
      end

      context 'manga' do
        let(:entry) { create :manga }
        it { expect(view.linked).to eq entry }
      end

      context 'character' do
        let(:entry) { create :character }
        it { expect(view.linked).to eq entry }
      end
    end

    context 'clubs' do
      let(:permalink) { 'clubs' }
      let(:entry) { create :club }

      it { expect(view.linked).to eq entry }
    end

    context 'reviews' do
      let(:permalink) { 'reviews' }
      let(:entry) { create :review }

      it { expect(view.linked).to eq entry }
    end

    context 'other' do
      let(:params) { { linked: 'zzz' } }
      let(:permalink) { 'other' }

      it { expect(view.linked).to be_nil }
    end

    context 'no linekd' do
      let(:params) { {} }
      let(:permalink) {}

      it { expect(view.linked).to be_nil }
    end
  end

  describe '#page' do
    context 'no page' do
      let(:params) { {} }
      it { expect(view.page).to eq 1 }
    end

    context 'with page' do
      let(:params) { { page: 2 } }
      it { expect(view.page).to eq 2 }
    end
  end
end
