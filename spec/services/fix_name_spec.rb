describe FixName do
  subject { described_class.call name, is_full_cleanup }
  let(:is_full_cleanup) { true }

  context 'nil' do
    let(:name) { nil }
    it { is_expected.to eq '' }
  end

  context 'forbidden symbols' do
    let(:name) { "test#[]%&?+@" }

    context 'full cleanup' do
      it { is_expected.to eq 'test' }
    end

    context 'no cleanup' do
      let(:is_full_cleanup) { false }
      it { is_expected.to eq name }
    end
  end

  context 'abusive words' do
    let(:name) { 'test [хуй]' }
    it { is_expected.to eq 'test xxx' }
  end

  context 'extension' do
    let(:name) { 'test.png' }
    it { is_expected.to eq 'test_png' }
  end

  context 'special spaces' do
    let(:name) { 't⠀t' }
    it { is_expected.to eq 't t' }
  end

  context 'special symbols' do
    let(:name) { ["007F".to_i(16)].pack("U*") }
    it { is_expected.to eq '' }
  end
end
