describe BbCodes::Tags::SizeTag do
  subject { described_class.instance.format text }
  let(:max_size) { described_class::MAXIMUM_FONT_SIZE }

  context 'small size' do
    let(:text) { '[size=13]test[/size]' }
    it { is_expected.to eq '<span style="font-size: 13px;">test</span>' }
  end

  context 'large size' do
    let(:text) { "[size=#{max_size}]test[/size]" }
    it { is_expected.to eq "<span style=\"font-size: #{max_size}px;\">test</span>" }
  end

  context 'too large size' do
    let(:text) { "[size=#{max_size + 1}]test[/size]" }
    it { is_expected.to eq "<span style=\"font-size: #{max_size}px;\">test</span>" }
  end

  context 'newline' do
    let(:text) { '[size=16]\n\rtest\n[/size]' }
    it { is_expected.to eq '<span style="font-size: 16px;">\\n\\rtest\\n</span>' }
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
