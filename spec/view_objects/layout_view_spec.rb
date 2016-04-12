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
