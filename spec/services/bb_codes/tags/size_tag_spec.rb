describe BbCodes::Tags::SizeTag do
  let(:tag) { BbCodes::Tags::SizeTag.instance }
  subject { tag.format text }

  context 'small size' do
    let(:text) { '[size=13]test[/size]' }
    it { is_expected.to eq '<span style="font-size: 13px;">test</span>' }
  end

  context 'large size' do
    let(:text) { '[size=26]test[/size]' }
    it { is_expected.to eq '<span style="font-size: 26px;">test</span>' }
  end

  context 'too large size' do
    let(:text) { '[size=27]test[/size]' }
    it { is_expected.to eq '<span style="font-size: 26px;">test</span>' }
  end
end
