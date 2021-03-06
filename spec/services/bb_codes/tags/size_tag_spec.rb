describe BbCodes::Tags::SizeTag do
  subject { described_class.instance.format text }

  context 'small size' do
    let(:text) { '[size=13]test[/size]' }
    it { is_expected.to eq '<span style="font-size: 13px;">test</span>' }
  end

  context 'large size' do
    let(:text) { '[size=36]test[/size]' }
    it { is_expected.to eq '<span style="font-size: 35px;">test</span>' }
  end

  context 'newline' do
    let(:text) { '[size=16]\n\rtest\n[/size]' }
    it { is_expected.to eq '<span style="font-size: 16px;">\\n\\rtest\\n</span>' }
  end

  context 'too large size' do
    let(:text) { '[size=27]test[/size]' }
    it { is_expected.to eq '<span style="font-size: 26px;">test</span>' }
  end

  context 'multiple tags' do
    let(:text) { '[size=13]test[/size]test2[size=14]test3[/size]' }
    it do
      is_expected.to eq(
        '<span style="font-size: 13px;">test</span>' \
          'test2' \
          '<span style="font-size: 14px;">test3</span>'
      )
    end
  end
end
