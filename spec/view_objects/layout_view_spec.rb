describe LayoutView do
  include_context :seeds
  include_context :view_object_warden_stub

  let(:view) { LayoutView.new }

  before do
    allow(view.h.controller).to receive(:instance_variable_get)
      .with('@blank_layout').and_return is_blank_layout
    allow(view.h).to receive(:current_user).and_return current_user
  end
  let(:is_blank_layout) { false }
  let(:current_user) { user }

  describe '#body_id' do
    let(:controller_name) { 'foo' }
    let(:action_name) { 'boo' }

    before { allow(view.h).to receive(:controller_name).and_return controller_name }
    before { allow(view.h).to receive(:action_name).and_return action_name }

    it { expect(view.body_id).to eq 'foo_boo' }
  end

  describe '#localized_names_class & #localized_genres_class' do
    before do
      allow(I18n).to receive(:russian?).and_return is_i18n_russian
      allow(view.h).to receive(:ru_domain?).and_return is_ru_domain
      allow(view.h).to receive(:user_signed_in?).and_return is_user_signed_in
      allow(view.h.current_user).to receive(:preferences).and_return double(
        russian_names: is_russian_names,
        russian_genres: is_russian_genres
      )
    end

    let(:is_i18n_russian) { true }
    let(:is_ru_domain) { true }
    let(:is_user_signed_in) { true }
    let(:is_russian_names) { true }
    let(:is_russian_genres) { true }

    it { expect(view.localized_names_class).to eq 'localized_names-ru' }
    it { expect(view.localized_genres_class).to eq 'localized_genres-ru' }

    context 'not russian locale' do
      let(:is_i18n_russian) { false }
      it { expect(view.localized_names_class).to eq 'localized_names-en' }
      it { expect(view.localized_genres_class).to eq 'localized_genres-en' }
    end

    context 'not russian domain' do
      let(:is_ru_domain) { false }
      it { expect(view.localized_names_class).to eq 'localized_names-en' }
      it { expect(view.localized_genres_class).to eq 'localized_genres-en' }
    end

    context 'user not signed in' do
      let(:is_user_signed_in) { false }
      it { expect(view.localized_names_class).to eq 'localized_names-ru' }
      it { expect(view.localized_genres_class).to eq 'localized_genres-ru' }
    end

    context 'disabled russian_names' do
      let(:is_russian_names) { false }
      it { expect(view.localized_names_class).to eq 'localized_names-en' }
      it { expect(view.localized_genres_class).to eq 'localized_genres-ru' }
    end

    context 'disabled russian_genres' do
      let(:is_russian_genres) { false }
      it { expect(view.localized_names_class).to eq 'localized_names-ru' }
      it { expect(view.localized_genres_class).to eq 'localized_genres-en' }
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
    let(:controller_user) { nil }
    let(:background) { '#fff' }

    before do
      allow(view.h.controller).to receive(:instance_variable_get)
        .with('@user').and_return controller_user
    end
    before { user.preferences.body_background = background }

    subject { view.background_styles }

    context 'current_user' do
      let(:camo_url) { UrlGenerator.instance.camo_url url }

      context 'url background' do
        let(:background) { 'http://test.com' }
        let(:camo_background_url) { UrlGenerator.instance.camo_url background }
        it { is_expected.to eq "background: url(#{camo_background_url}) fixed no-repeat;" }
      end

      context 'simple background' do
        it { is_expected.to eq "background: #{background};" }
      end

      context 'complex background' do
        let(:url) { 'http://nyaa.shikimori.org/system/user_images/original/1/288070.jpg' }
        let(:background) { "url(#{url}) no-repeat fixed" }
        let(:fixed_background) { "url(#{camo_url}) no-repeat fixed" }
        it { is_expected.to eq "background: #{fixed_background};" }
      end

      context 'more complex background' do
        let(:url) { 'https://pp.vk.me/c625818/v625818569/3d111/Z_LiM2lgwuA.jpg' }
        let(:background) { "url(#{url}); background-size: 100%; background-attachment: fixed;  background-repeat:no-repeat" }
        let(:fixed_background) { "url(#{camo_url}); background-size: 100%; background-attachment: fixed;  background-repeat:no-repeat" }
        it { is_expected.to eq "background: #{fixed_background};" }
      end
    end

    context 'object_with_background' do
      let(:controller_user) do
        double preferences: double(body_background: controller_user_background)
      end

      context 'with current_user' do
        let(:controller_user_background) { '#fff' }
        it { is_expected.to eq "background: #{controller_user_background};" }
      end

      context 'without current_user' do
        let(:current_user) { nil }
        let(:controller_user_background) { '#fff' }
        it { is_expected.to eq "background: #{controller_user_background};" }
      end
    end

    context 'no current_user' do
      let(:current_user) { nil }
      it { is_expected.to be_nil }
    end

    context 'blank_layout' do
      let(:is_blank_layout) { true }
      it { is_expected.to be_nil }
    end
  end

  describe '#user_data' do
    context 'user' do
      let!(:topic_ignore) { create :topic_ignore, user: current_user, topic: offtopic_topic }
      let!(:user_ignore) { create :ignore, user: current_user, target: ignored_user }
      let(:ignored_user) { create :user }

      it do
        expect(view.user_data).to eq(
          id: current_user.id,
          is_moderator: current_user.moderator?,
          ignored_topics: [offtopic_topic.id],
          ignored_users: [ignored_user.id]
        )
      end
    end

    context 'guest' do
      let(:current_user) { nil }

      it do
        expect(view.user_data).to eq(
          id: nil,
          is_moderator: false,
          ignored_topics: [],
          ignored_users: []
        )
      end
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
end
