describe BbCodes::Tags::SpoilerTag do
  subject { described_class.instance.format text }

  describe '[spoiler=text]' do
    let(:text) { '[spoiler=1]test[/spoiler]' }
    it do
      is_expected.to eq(
        <<~HTML.squish
          <div class='b-spoiler unprocessed'><label>1</label><div class='content'><div
            class='before'></div><div class='inner'>test</div><div
            class='after'></div></div></div>
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
