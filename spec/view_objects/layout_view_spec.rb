describe LayoutView do
  include_context :view_context_stub

  let(:view) { described_class.new }

  before do
    allow(view.h.controller)
      .to receive(:instance_variable_get)
      .with('@blank_layout')
      .and_return is_blank_layout
  end
  let(:is_blank_layout) { false }

  describe '#body_id, #body_class' do
    let(:controller_name) { 'animes' }
    let(:action_name) { 'show' }

    before do
      allow(view.h).to receive(:controller_name).and_return controller_name
      allow(view.h).to receive(:action_name).and_return action_name
      allow(view.h.controller).to receive(:class).and_return AnimesController
    end

    it { expect(view.body_id).to eq 'animes_show' }
    it { expect(view.body_class).to eq 'p-animes p-animes-show p-db_entries p-db_entries-show x1200' }
  end

  describe '#localized_names & #localized_genres' do
    before do
      allow(I18n).to receive(:russian?).and_return is_i18n_russian
      allow(view.h).to receive(:ru_host?).and_return is_ru_host
      allow(view.h).to receive(:user_signed_in?).and_return is_user_signed_in
      allow(view.h.current_user).to receive(:preferences).and_return double(
        russian_names: is_russian_names,
        russian_genres: is_russian_genres
      )
    end

    let(:is_i18n_russian) { true }
    let(:is_ru_host) { true }
    let(:is_user_signed_in) { true }
    let(:is_russian_names) { true }
    let(:is_russian_genres) { true }

    it { expect(view.localized_names).to eq :ru }
    it { expect(view.localized_genres).to eq :ru }

    context 'not russian locale' do
      let(:is_i18n_russian) { false }
      it { expect(view.localized_names).to eq :en }
      it { expect(view.localized_genres).to eq :en }
    end

    context 'not russian domain' do
      let(:is_ru_host) { false }
      it { expect(view.localized_names).to eq :en }
      it { expect(view.localized_genres).to eq :en }
    end

    context 'user not signed in' do
      let(:is_user_signed_in) { false }
      it { expect(view.localized_names).to eq :ru }
      it { expect(view.localized_genres).to eq :ru }
    end

    context 'disabled russian_names' do
      let(:is_russian_names) { false }
      it { expect(view.localized_names).to eq :en }
      it { expect(view.localized_genres).to eq :ru }
    end

    context 'disabled russian_genres' do
      let(:is_russian_genres) { false }
      it { expect(view.localized_names).to eq :ru }
      it { expect(view.localized_genres).to eq :en }
    end
  end

  describe '#blank_layout?' do
    context 'blank' do
      let(:is_blank_layout) { true }
      it { expect(view).to be_blank_layout }
    end

    context 'not blank' do
      let(:is_blank_layout) { false }
      it { expect(view).to_not be_blank_layout }
    end
  end

  describe '#background_styles' do
    before do
      allow(view.h.controller)
        .to receive(:instance_variable_get)
        .with('@user')
        .and_return user
      allow(view.h.controller)
        .to receive(:instance_variable_get)
        .with('@club')
        .and_return nil
    end

    it do
      expect(view.custom_styles).to eq(
        "<style id=\"#{LayoutView::CUSTOM_CSS_ID}\" type=\"text/css\"></style>"
      )
    end
  end

  describe '#user_data' do
    context 'user' do
      let!(:topic_ignore) do
        create :topic_ignore, user: user, topic: offtopic_topic
      end
      let!(:user_ignore) do
        create :ignore, user: user, target: ignored_user
      end
      let(:ignored_user) { create :user }

      it do
        expect(view.user_data).to eq(
          id: user.id,
          url: user.decorate.url,
          is_moderator: user.forum_moderator?,
          ignored_topics: [offtopic_topic.id],
          ignored_users: [ignored_user.id],
          is_day_registered: false,
          is_week_registered: false,
          is_comments_auto_collapsed: true,
          is_comments_auto_loaded: true
        )
      end
    end

    context 'guest' do
      let(:user) { nil }

      it do
        expect(view.user_data).to eq(
          id: nil,
          url: nil,
          is_moderator: false,
          ignored_topics: [],
          ignored_users: [],
          is_day_registered: false,
          is_week_registered: false,
          is_comments_auto_collapsed: true,
          is_comments_auto_loaded: false
        )
      end
    end
  end

  describe '#hot_topics?' do
    let(:view_context_params) do
      {
        controller: controller_name,
        action: controller_action
      }
    end
    let(:controller_action) { 'index' }

    # context 'dashboards' do
    #   let(:controller_name) { 'dashboards' }
    #   it { expect(view).to_not be_hot_topics }
    # end

    context 'topics' do
      let(:controller_name) { 'topics' }

      context 'index' do
        let(:controller_action) { 'index' }
        it { expect(view).to be_hot_topics }
      end

      context 'show' do
        let(:controller_action) { 'show' }
        it { expect(view).to_not be_hot_topics }
      end
    end

    context 'animes' do
      let(:controller_name) { 'animes' }
      it { expect(view).to_not be_hot_topics }
    end

    context 'profiles' do
      let(:controller_name) { 'profiles' }
      it { expect(view).to_not be_hot_topics }
    end
  end

  describe '#hot_topics' do
    before { allow(Topics::HotTopicsQuery).to receive(:call).and_return topics }
    let(:topics) { [offtopic_topic] }
    it do
      expect(view.hot_topics).to have(1).item
      expect(view.hot_topics.first).to be_kind_of Topics::View
      expect(view.hot_topics.first.topic).to eq offtopic_topic
    end
  end

  describe '#moderation_policy' do
    it { expect(view.moderation_policy).to be_kind_of ModerationPolicy }
  end
end
