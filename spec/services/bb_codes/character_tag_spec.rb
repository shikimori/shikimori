describe BbCodes::CharacterTag do
  let(:tag) { BbCodes::CharacterTag.instance }

  describe '#format' do
    subject { tag.format text }
    let(:character) { create :character, id: 9876543, name: 'zxcvbn', russian: nil }

    let(:html) do
      <<-HTML.squish
<a href="//test.host/characters/9876543-zxcvbn" title="zxcvbn"
class="bubbled b-link"
data-tooltip_url="//test.host/characters/9876543-zxcvbn/tooltip">zxcvbn</a>
        HTML
    end

    let(:text) { "[character=#{character.id}]" }
    it { is_expected.to eq html }
  end
end
