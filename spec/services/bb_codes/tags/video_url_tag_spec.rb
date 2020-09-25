describe BbCodes::Tags::VideoUrlTag do
  subject { described_class.instance.format text }
  let(:text) { url }
  let(:url) { 'https://www.youtube.com/watch?v=og2a5lngYeQ' }

  it { is_expected.to eq "[video]#{url}[/video]" }

  context 'with text' do
    let(:text) { "zzz #{url}" }
    it { is_expected.to eq "zzz [video]#{url}[/video]" }
  end

  context 'wrapped in url' do
    let(:text) { "[url]https://www.youtube.com/watch?v=#{hash}[/url]" }
    it { is_expected.to eq text }

    context '[url=...]' do
      let(:text) { "[url=#{url}]#{url}[/url]" }
      it { is_expected.to eq text }
    end
  end

  context 'wrapped in video' do
    let(:text) { "[video]https://www.youtube.com/watch?v=#{hash}[/video]" }
    it { is_expected.to eq text }
  end
end
