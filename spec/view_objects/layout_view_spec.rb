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

  describe '#localized_names_class' do
    before do
      allow(I18n).to receive(:russian?).and_return is_i18n_russian
      allow(view.h).to receive(:ru_domain?).and_return is_ru_domain
      allow(view.h).to receive(:user_signed_in?).and_return is_user_signed_in
      allow(view.h.current_user).to receive(:preferences)
        .and_return double(russian_names: is_russian_names)
    end

    let(:is_i18n_russian) { true }
    let(:is_ru_domain) { true }
    let(:is_user_signed_in) { true }
    let(:is_russian_names) { true }

    it { expect(view.localized_names_class).to eq 'localized_names-ru' }

    context 'not russian locale' do
      let(:is_i18n_russian) { false }
      it { expect(view.localized_names_class).to eq 'localized_names-en' }
    end

    context 'not russian domain' do
      let(:is_ru_domain) { false }
      it { expect(view.localized_names_class).to eq 'localized_names-en' }
    end

    context 'user not signed in' do
      let(:is_user_signed_in) { false }
      it { expect(view.localized_names_class).to eq 'localized_names-ru' }
    end

    context 'disabled russian_names' do
      let(:is_russian_names) { false }
      it { expect(view.localized_names_class).to eq 'localized_names-en' }
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
    let(:current_user_background) { '#fff' }

    before do
      allow(view.h.controller).to receive(:instance_variable_get)
        .with('@user').and_return controller_user
    end
    before { user.preferences.body_background = current_user_background }

    subject { view.background_styles }

    context 'current_user' do
      context 'url background' do
        let(:current_user_background) { 'http://test.com' }
        it { is_expected.to eq "background: url(#{current_user_background}) fixed no-repeat;" }
      end

      context 'simple background' do
        it { is_expected.to eq "background: #{current_user_background};" }
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
end
