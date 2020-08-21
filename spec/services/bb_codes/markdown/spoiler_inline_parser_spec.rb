describe BbCodes::Markdown::SpoilerInlineParser do
  subject { described_class.instance.format text }

  context 'sample' do
    let(:text) { '||test||' }
    it do
      is_expected.to eq(
        <<~HTML.squish
          <button class='b-spoiler_inline to-process'
            data-dynamic='spoiler_inline'><span>test</span></button>
        HTML
      )
    end
  end

  context 'sample' do
    let(:text) { 'a ||test|| b' }
    it do
      is_expected.to eq(
        <<~HTML.squish
          a <button class='b-spoiler_inline to-process'
            data-dynamic='spoiler_inline'><span>test</span></button> b
        HTML
      )
    end
  end

  context 'sample' do
    let(:text) { '||a|| ||b||' }
    it do
      is_expected.to eq(
        <<~HTML.squish
          <button class='b-spoiler_inline to-process'
            data-dynamic='spoiler_inline'><span>a</span></button>
          <button class='b-spoiler_inline to-process'
            data-dynamic='spoiler_inline'><span>b</span></button>
        HTML
      )
    end
  end

  context 'sample' do
    let(:text) { "a ||te\nst|| b" }
    it { is_expected.to eq text }
  end
end
