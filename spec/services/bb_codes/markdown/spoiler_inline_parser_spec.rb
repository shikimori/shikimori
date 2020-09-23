describe BbCodes::Markdown::SpoilerInlineParser do
  subject { described_class.instance.format text }

  context 'sample' do
    let(:text) { '||test||' }
    it do
      is_expected.to eq(
        <<~HTML.squish
          #{described_class::TAG_OPEN}<span>test</span>#{described_class::TAG_CLOSE}
        HTML
      )
    end
  end

  context 'sample' do
    let(:text) { 'a ||test|| b' }
    it do
      is_expected.to eq(
        <<~HTML.squish
          a
          #{described_class::TAG_OPEN}<span>test</span>#{described_class::TAG_CLOSE}
          b
        HTML
      )
    end
  end

  context 'sample' do
    let(:text) { '||a|| ||b||' }
    it do
      is_expected.to eq(
        <<~HTML.squish
          #{described_class::TAG_OPEN}<span>a</span>#{described_class::TAG_CLOSE}
          #{described_class::TAG_OPEN}<span>b</span>#{described_class::TAG_CLOSE}
        HTML
      )
    end
  end

  context 'sample' do
    let(:text) { "a ||te\nst|| b" }
    it { is_expected.to eq text }
  end

  context 'sample' do
    let(:text) { 'a ||te[spoiler]st|| b' }
    it { is_expected.to eq text }
  end

  context 'sample' do
    let(:text) { 'a ||te[*]st|| b' }
    it { is_expected.to eq text }
  end
end
