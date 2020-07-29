describe BbCodes::Tags::CharacterTag do
  subject { described_class.instance.format text }

  let(:character) { create :character, id: 9876543, name: 'zxcvbn', russian: '' }
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
