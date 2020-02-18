describe BbCodes::Tags::CharacterTag do
  let(:tag) { BbCodes::Tags::CharacterTag.instance }

  describe '#format' do
    subject { tag.format text }
    let(:character) do
      create :character,
        id: 9876543,
        name: 'zxcvbn',
        russian: ''
    end

    let(:html) do
      <<-HTML.squish
        <a href="#{Shikimori::PROTOCOL}://test.host/characters/9876543-zxcvbn" title="zxcvbn"
        class="bubbled b-link"
        data-tooltip_url="#{Shikimori::PROTOCOL}://test.host/characters/9876543-zxcvbn/tooltip">zxcvbn</a>
      HTML
    end

    let(:text) { "[character=#{character.id}]" }
    it { is_expected.to eq html }
  end
end
