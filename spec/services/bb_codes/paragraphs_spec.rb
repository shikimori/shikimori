describe BbCodes::Paragraphs do
  subject { described_class.call text }
  let(:long_line) { 'x' * described_class::LINE_SIZE }

  describe 'sample' do
    let(:text) { long_line }
    it { is_expected.to eq "[p]#{long_line}[/p]" }
  end

  describe 'sample' do
    let(:text) { "#{long_line}1\n#{long_line}2\n333" }
    it { is_expected.to eq "[p]#{long_line}1[/p][p]#{long_line}2[/p]333" }
  end

  # describe '<br>' do
  #   let(:text) { "#{long_line}1<br>#{long_line}2<br />333" }
  #   it { is_expected.to eq "[p]#{long_line}1[/p][p]#{long_line}2[/p]333" }
  # end

  # describe '&lt;br&gt;' do
  #   let(:text) { "#{long_line}1&lt;br&gt;#{long_line}2&lt;br/&gt;333" }
  #   it { is_expected.to eq "[p]#{long_line}1[/p][p]#{long_line}2[/p]333" }
  # end

  describe '[*]' do
    let(:text) { "[list]\n [*]z\r\n[/list]" }
    it { is_expected.to eq "[list]\n[*]z\r\n[/list]" }

    context 'more [*]' do
      let(:text) { "[list][*]z[*]x\n[*]c[/list]" }
      it { is_expected.to eq "[list]\n[*]z\n[*]x\n[*]c[/list]" }
    end

    context '\n before [*]' do
      let(:text) { "test\n\n[*]z" }
      it { is_expected.to eq "test\n\n[*]z" }
    end
  end

  context 'markdown list or quote' do
    let(:prefix) { %w[- + * >].sample }
    let(:text) { "#{prefix} #{long_line}" }
    it { is_expected.to eq text }
  end

  describe '[quote]' do
    let(:text) { '[quote]zzz' }
    it { is_expected.to eq "[quote]\nzzz" }
  end
end
