describe CharactersService do
  let (:processor) { CharactersService.instance }

  let (:anime) { create :anime }
  let (:character1) { create :character, japanese: 'ドイツ', russian: 'Ода Нобунага', name: 'Oda Nobunaga' }
  let (:character2) { create :character, japanese: 'イタリア', russian: 'Ода Бобунага', name: 'Oda Bobunaga' }
  let (:person1) { create :person, japanese: '新海 誠' }

  before (:each) do
    anime.characters << character1
    anime.characters << character2
    anime.people << person1
  end

  describe Character do
    describe 'russian' do
      it 'works' do
        processor.process("test #{character1.russian}", anime).should ==
          "test [character=#{character1.id}]#{character1.russian}[/character]"
      end

      it 'replaced anywhere if once matched' do
        processor.process("test #{character1.russian} test #{character1.russian.split(' ').first}", anime).should ==
          "test [character=#{character1.id}]#{character1.russian}[/character] test [character=#{character1.id}]#{character1.russian.split(' ').first}[/character]"
      end

      it 'ambigious ignored' do
        processor.process("test #{character1.russian} test #{character2.russian} test #{character1.russian.split(' ').first}", anime).should ==
          "test [character=#{character1.id}]#{character1.russian}[/character] test [character=#{character2.id}]#{character2.russian}[/character] test #{character1.russian.split(' ').first}"
      end
    end

    describe 'english' do
      it 'works' do
        processor.process("test Вася [#{character1.name}]", anime).should ==
          "test [character=#{character1.id}]Вася[/character]"

      end
    end

    describe 'japanese' do
      it 'works' do
        processor.process("test Вася [#{character1.japanese}]", anime).should ==
          "test [character=#{character1.id}]Вася[/character]"
      end

      it 'ingnores text in [[ ]]' do
        processor.process("[[Вася]] Вася [#{character1.japanese}]", anime).should ==
          "[[Вася]] [character=#{character1.id}]Вася[/character]"
      end

      it 'Викторика де Блуа' do
        processor.process("Викторика де Блуа[#{character1.japanese}]", anime).should ==
          "[character=#{character1.id}]Викторика де Блуа[/character]"
      end

      it 'Краузер VI' do
        processor.process("Краузер VI[#{character1.japanese}]", anime).should ==
          "[character=#{character1.id}]Краузер VI[/character]"
      end

      it 'w/o space' do
        processor.process("Вася[#{character1.japanese}]", anime).should ==
          "[character=#{character1.id}]Вася[/character]"
      end

      it 'weird space' do
        processor.process("test Вася [#{character1.japanese}]", anime).should ==
          "test [character=#{character1.id}]Вася[/character]"
      end

      it 'beginning position' do
        processor.process("Вася [#{character1.japanese}]", anime).should ==
          "[character=#{character1.id}]Вася[/character]"
      end

      it '2 words' do
        processor.process("test Вёся Ёся [#{character1.japanese}]", anime).should ==
          "test [character=#{character1.id}]Вёся Ёся[/character]"
      end

      it 'with dot' do
        processor.process("test Вёся. Ёся [#{character1.japanese}]", anime).should ==
          "test [character=#{character1.id}]Вёся. Ёся[/character]"
      end

      it '3 words' do
        processor.process("test Ао Аи Ая [#{character1.japanese}]", anime).should ==
          "test [character=#{character1.id}]Ао Аи Ая[/character]"
      end

      it '4 words' do
        processor.process("test Ао Аи Ая Ае [#{character1.japanese}]", anime).should ==
          "test [character=#{character1.id}]Ао Аи Ая Ае[/character]"
      end

      it 'half name' do
        processor.process("test Вёся Ёся [#{character1.japanese}]. Ёся.", anime).should ==
          "test [character=#{character1.id}]Вёся Ёся[/character]. [character=#{character1.id}]Ёся[/character]."
      end

      it 'both braces' do
        processor.process("test Вася (#{character1.japanese})", anime).should ==
          "test [character=#{character1.id}]Вася[/character]"
      end

      it 'does nothing for non matched' do
        processor.process("test Вася [イリア]", anime).should == "test Вася [イリア]"
      end

      it 'two times' do
        processor.process("test Вася [#{character1.japanese}], Вася.", anime).should ==
          "test [character=#{character1.id}]Вася[/character], [character=#{character1.id}]Вася[/character]."
      end

      it 'multiple characters' do
        processor.process("test Вася [#{character1.japanese}], Мася[#{character2.japanese}].", anime).should ==
          "test [character=#{character1.id}]Вася[/character], [character=#{character2.id}]Мася[/character]."
      end

      it 'multiple characters with ambigious name' do
        processor.process("test Вася Ёся [#{character1.japanese}], Мася Ёся [#{character2.japanese}]. Ёся. Вася.", anime).should ==
          "test [character=#{character1.id}]Вася Ёся[/character], [character=#{character2.id}]Мася Ёся[/character]. Ёся. [character=#{character1.id}]Вася[/character]."
      end

      it 'russian variations' do
        processor.process("Вася [#{character1.japanese}], Васи, Васе, Васей, Васю.", anime).should ==
          "[character=#{character1.id}]Вася[/character], [character=#{character1.id}]Васи[/character], [character=#{character1.id}]Васе[/character], [character=#{character1.id}]Васей[/character], [character=#{character1.id}]Васю[/character]."
      end

      it 'ignores pretext' do
        processor.process("Но Вася [#{character1.japanese}]", anime).should ==
          "Но [character=#{character1.id}]Вася[/character]"
      end
    end
  end

  describe Person do
    it 'works' do
      processor.process("test Вася [#{person1.japanese}]", anime).should ==
        "test [person=#{person1.id}]Вася[/person]"
    end
  end

  describe "Person+Character" do
    it 'works' do
      processor.process("test Вася [#{person1.japanese}] Мася [#{character1.japanese}]", anime).should ==
        "test [person=#{person1.id}]Вася[/person] [character=#{character1.id}]Мася[/character]"
    end
  end
end
