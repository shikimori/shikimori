describe Localization::RussianNamesPolicy do
  subject { described_class.call user }
  before { allow(I18n).to receive(:russian?).and_return is_russian }

  context 'no user' do
    let(:user) { nil }

    context 'russian locale' do
      let(:is_russian) { true }
      it { is_expected.to eq true }
    end

    context 'not russian locale' do
      let(:is_russian) { false }
      it { is_expected.to eq false }
    end
  end

  context 'has user' do
    let(:user) { build :user }
    before do
      allow(user)
        .to receive_message_chain(:preferences, :russian_names?)
        .and_return is_russian_names
    end

    context 'russian locale' do
      let(:is_russian) { true }

      context 'russian_names' do
        let(:is_russian_names) { true }
        it { is_expected.to eq true }
      end

      context 'not russian_names' do
        let(:is_russian_names) { false }
        it { is_expected.to eq false }
      end
    end

    context 'not russian locale' do
      let(:is_russian) { false }

      context 'russian_names' do
        let(:is_russian_names) { true }
        it { is_expected.to eq true }
      end

      context 'not russian_names' do
        let(:is_russian_names) { false }
        it { is_expected.to eq false }
      end
    end
  end
end
