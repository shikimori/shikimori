describe BbCodes::Tags::SpoilerTag do
  subject { described_class.instance.format text }

  describe 'old style' do
    let(:text) { 'q [spoiler=1]test[/spoiler] w' }
    it do
      is_expected.to eq(
        <<~HTML.squish
          q <div class='b-spoiler unprocessed'><label>1</label><div class='content'><div
            class='before'></div><div class='inner'>test</div><div
            class='after'></div></div></div> w
        HTML
      )
    end
  end

  describe 'block' do
    let(:prefix) { ["\n", ''].sample }
    let(:text) { "#{prefix}[spoiler=1]test[/spoiler] qwe" }

    it do
      is_expected.to eq(
        prefix +
          <<~HTML.squish
            <div class='b-spoiler_block to-process'
              data-dynamic='spoiler_block'><button>1</button><div><p>test</p></div></div>
              qwe
          HTML
      )
    end
  end

  describe '[spoiler]' do
    let(:text) { '[spoiler]test[/spoiler]' }
    it { is_expected.to_not include '[spoiler' }
  end

  describe 'nested [spoiler]' do
    let(:text) { '[spoiler=test] [spoiler=1]test[/spoiler][/spoiler]' }
    it { is_expected.to_not include '[spoiler' }
  end
end
