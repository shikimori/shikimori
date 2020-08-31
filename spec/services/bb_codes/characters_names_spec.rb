describe BbCodes::CharactersNames do
  let(:anime) { create :anime }
  let(:character1) { create :character, japanese: 'ドイツ', russian: 'Ода Нобунага', name: 'Oda Nobunaga' }
  let(:character2) { create :character, japanese: 'イタリア', russian: 'Ода Бобунага', name: 'Oda Bobunaga' }
  let(:person1) { create :person, japanese: '新海 誠' }

  before do
    anime.characters << character1
    anime.characters << character2
    anime.people << person1
  end

  context 'Character' do
    context 'russian' do
      it do
        expect(described_class.call("test #{character1.russian}", anime)).to eq(
          "test [character=#{character1.id}]#{character1.russian}[/character]"
        )
      end

      it 'replaced anywhere if once matched' do
        expect(described_class.call("test #{character1.russian} test #{character1.russian.split(' ').first}", anime)).to eq(
          "test [character=#{character1.id}]#{character1.russian}[/character] test [character=#{character1.id}]#{character1.russian.split(' ').first}[/character]"
        )
      end

      it 'ambigious ignored' do
        expect(described_class.call("test #{character1.russian} test #{character2.russian} test #{character1.russian.split(' ').first}", anime)).to eq(
          "test [character=#{character1.id}]#{character1.russian}[/character] test [character=#{character2.id}]#{character2.russian}[/character] test #{character1.russian.split(' ').first}"
        )
      end
    end

    context 'context' do
      it do
        expect(described_class.call("test Вася [#{character1.name}]", anime)).to eq(
          "test [character=#{character1.id}]Вася[/character]"
        )
      end
    end

    context 'japanese' do
      it 'works' do
        expect(described_class.call("test Вася [#{character1.japanese}]", anime)).to eq(
          "test [character=#{character1.id}]Вася[/character]"
        )
      end

      it 'ingnores text in [[ ]]' do
        expect(described_class.call("[[Вася]] Вася [#{character1.japanese}]", anime)).to eq(
          "[[Вася]] [character=#{character1.id}]Вася[/character]"
        )
      end

      it 'Викторика де Блуа' do
        expect(described_class.call("Викторика де Блуа[#{character1.japanese}]", anime)).to eq(
          "[character=#{character1.id}]Викторика де Блуа[/character]"
        )
      end

      it 'Краузер VI' do
        expect(described_class.call("Краузер VI[#{character1.japanese}]", anime)).to eq(
          "[character=#{character1.id}]Краузер VI[/character]"
        )
      end

      it 'w/o space' do
        expect(described_class.call("Вася[#{character1.japanese}]", anime)).to eq(
          "[character=#{character1.id}]Вася[/character]"
        )
      end

      it 'weird space' do
        expect(described_class.call("test Вася [#{character1.japanese}]", anime)).to eq(
          "test [character=#{character1.id}]Вася[/character]"
        )
      end

      it 'beginning position' do
        expect(described_class.call("Вася [#{character1.japanese}]", anime)).to eq(
          "[character=#{character1.id}]Вася[/character]"
        )
      end

      it '2 words' do
        expect(described_class.call("test Вёся Ёся [#{character1.japanese}]", anime)).to eq(
          "test [character=#{character1.id}]Вёся Ёся[/character]"
        )
      end

      it 'with dot' do
        expect(described_class.call("test Вёся. Ёся [#{character1.japanese}]", anime)).to eq(
          "test [character=#{character1.id}]Вёся. Ёся[/character]"
        )
      end

      it '3 words' do
        expect(described_class.call("test Ао Аи Ая [#{character1.japanese}]", anime)).to eq(
          "test [character=#{character1.id}]Ао Аи Ая[/character]"
        )
      end

      it '4 words' do
        expect(described_class.call("test Ао Аи Ая Ае [#{character1.japanese}]", anime)).to eq(
          "test [character=#{character1.id}]Ао Аи Ая Ае[/character]"
        )
      end

      it 'half name' do
        expect(described_class.call("test Вёся Ёся [#{character1.japanese}]. Ёся.", anime)).to eq(
          "test [character=#{character1.id}]Вёся Ёся[/character]. [character=#{character1.id}]Ёся[/character]."
        )
      end

      it 'both braces' do
        expect(described_class.call("test Вася (#{character1.japanese})", anime)).to eq(
          "test [character=#{character1.id}]Вася[/character]"
        )
      end

      it 'does nothing for non matched' do
        expect(described_class.call('test Вася [イリア]', anime)).to eq('test Вася [イリア]')
      end

      it 'two times' do
        expect(described_class.call("test Вася [#{character1.japanese}], Вася.", anime)).to eq(
          "test [character=#{character1.id}]Вася[/character], [character=#{character1.id}]Вася[/character]."
        )
      end

      it 'multiple characters' do
        expect(described_class.call("test Вася [#{character1.japanese}], Мася[#{character2.japanese}].", anime)).to eq(
          "test [character=#{character1.id}]Вася[/character], [character=#{character2.id}]Мася[/character]."
        )
      end

      it 'multiple characters with ambigious name' do
        expect(described_class.call("test Вася Ёся [#{character1.japanese}], Мася Ёся [#{character2.japanese}]. Ёся. Вася.", anime)).to eq(
          "test [character=#{character1.id}]Вася Ёся[/character], [character=#{character2.id}]Мася Ёся[/character]. Ёся. [character=#{character1.id}]Вася[/character]."
        )
      end

      it 'russian variations' do
        expect(described_class.call("Вася [#{character1.japanese}], Васи, Васе, Васей, Васю.", anime)).to eq(
          "[character=#{character1.id}]Вася[/character], [character=#{character1.id}]Васи[/character], [character=#{character1.id}]Васе[/character], [character=#{character1.id}]Васей[/character], [character=#{character1.id}]Васю[/character]."
        )
      end

      it 'ignores pretext' do
        expect(described_class.call("Но Вася [#{character1.japanese}]", anime)).to eq(
          "Но [character=#{character1.id}]Вася[/character]"
        )
      end
    end
  end

  context 'Person' do
    it do
      expect(described_class.call("test Вася [#{person1.japanese}]", anime)).to eq(
        "test [person=#{person1.id}]Вася[/person]"
      )
    end
  end

  context 'Person+Character' do
    it do
      expect(described_class.call("test Вася [#{person1.japanese}] Мася [#{character1.japanese}]", anime)).to eq(
        "test [person=#{person1.id}]Вася[/person] [character=#{character1.id}]Мася[/character]"
      )
    end
  end

  describe 'url tag is skipped' do
    let(:text) { "[test [url=...]abc #{character1.russian} [/url]zx" }
    it { expect(described_class.call(text, anime)).to eq text }
  end
end
