describe FixName do
  subject { described_class.call name, is_full_cleanup }

  context 'full cleanup' do
    let(:is_full_cleanup) { true }

    context 'nil' do
      let(:name) { nil }
      it { is_expected.to eq '' }
    end

    context 'forbidden symbols' do
      let(:name) { "test#[]%&?+@\"'><⁤⁧‮‍" }
      it { is_expected.to eq 'test' }
    end

    context 'special spaces' do
      let(:name) { 't⠀t' }
      it { is_expected.to eq 't t' }
    end

    context 'empty special unicode' do
      let(:name) { 't' + 917780.chr + 't' }
      it { is_expected.to eq 't t' }
    end

    context 'special symbols' do
      let(:name) { ['007F'.to_i(16)].pack('U*') }
      it { is_expected.to eq '' }
    end

    context 'abusive words' do
      let(:name) { 'test [хуй]' }
      it { is_expected.to eq 'test xxx' }
    end

    describe 'spam domains' do
      let(:name) { %w[images.webpark.ru shikme.ru].sample }
      it { is_expected.to eq BbCodes::Text::BANNED_TEXT }
    end

    context 'extension' do
      let(:name) { 'test.png' }
      it { is_expected.to eq 'test_png' }
    end
  end

  context 'not full cleanup' do
    let(:is_full_cleanup) { false }

    context 'nil' do
      let(:name) { nil }
      it { is_expected.to eq '' }
    end

    context 'forbidden symbols' do
      let(:name) { "test#[]%&?+@\"'><" }
      it { is_expected.to eq name }
    end

    context 'special spaces' do
      let(:name) { 't⠀t' }
      it { is_expected.to eq 't t' }
    end

    context 'special symbols' do
      let(:name) { ['007F'.to_i(16)].pack('U*') }
      it { is_expected.to eq '' }
    end

    context 'empty special unicode' do
      let(:name) { 't' + 917780.chr + 't' }
      it { is_expected.to eq 't t' }
    end

    context 'abusive words' do
      let(:name) { 'test [хуй]' }
      it { is_expected.to eq 'test [xxx]' }
    end

    describe 'spam domains' do
      let(:name) { %w[images.webpark.ru shikme.ru].sample }
      it { is_expected.to eq '[deleted]' }
    end

    context 'extension' do
      let(:name) { 'test.png' }
      it { is_expected.to eq name }
    end
  end
end
