describe FixName do
  let(:service) { FixName.new name }
  subject! { service.call }

  context 'nil' do
    let(:name) { nil }
    it { is_expected.to eq '' }
  end

  context 'forbidden symbols' do
    let(:name) { '#[test]%&?+@' }
    it { is_expected.to eq 'test' }
  end

  context 'abusive words' do
    let(:name) { 'test [хуй]' }
    it { is_expected.to eq 'test xxx' }
  end

  context 'extension' do
    let(:name) { 'test.png' }
    it { is_expected.to eq 'test_png' }
  end
end
