describe BbCodes::Markdown::SpoilerInlineParser do
  subject { described_class.instance.format text }

  context 'sample' do
    let(:text) { '||test||' }
    it do
      is_expected.to eq(
        <<~HTML.squish
          <span class='b-spoiler_inline' to-process'
            data-dynamic='spoiler_inline'><span>test</span></span>
        HTML
      )
    end
  end

  context 'sample' do
    let(:text) { 'a ||test|| b' }
    it do
      is_expected.to eq(
        <<~HTML.squish
          a <span class='b-spoiler_inline' to-process'
            data-dynamic='spoiler_inline'><span>test</span></span> b
        HTML
      )
    end
  end

  context 'sample' do
    let(:text) { "a ||te\nst|| b" }
    it { is_expected.to eq text }
  end
end
