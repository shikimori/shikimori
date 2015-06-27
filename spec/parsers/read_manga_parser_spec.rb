describe ReadMangaParser, vcr: { cassette_name: 'read_manga_parser' } do
  let(:parser) { ReadMangaParser.new }

  it { expect(parser.fetch_pages_num).to eq 87 }
  it { expect(parser.fetch_page_links(0).size).to eq(ReadMangaParser::PageSize) }
  it { expect(parser.fetch_page_links(parser.fetch_pages_num - 1).last).to eq 'wild_kiss' }

  describe 'cleanup description' do
    it { expect(parser.normalize_line("Яяя\r\nыыы.\r\nЗзз")).to eq "Яяя ыыы.\nЗзз" }
    it { expect(parser.normalize_line("a  a")).to eq "a a" }
    it { expect(parser.normalize_line("a a")).to eq "a a" }
  end

  describe 'extracts source' do
    it { expect(parser.extract_source('Site.ru')).to eq 'http://site.ru' }
    it { expect(parser.extract_source('http://site.ru')).to eq 'http://site.ru' }
    it { expect(parser.extract_source('© Алексей Мелихов, World Art')).to eq '© Алексей Мелихов, http://world-art.ru' }
    it { expect(parser.extract_source('Espada Clan (c)')).to eq ReadMangaImportData::MangaTeams['espada clan'] }
    it { expect(parser.extract_source('Copyright © Nomad Team')).to eq ReadMangaImportData::MangaTeams['nomad team'] }
    it { expect(parser.extract_source('Взято с animeshare.su')).to eq 'http://animeshare.su' }
    it { expect(parser.extract_source('(взято с animeshare.su)')).to eq 'http://animeshare.su' }
    it { expect(parser.extract_source('Kair', 'url')).to eq '© Kair, url' }
    it { expect(parser.extract_source('Описание составлено: BlaBlaBla', 'url')).to eq '© BlaBlaBla, url' }
    it { expect(parser.extract_source('Death Note - Kira Revival Project')).to eq 'http://deathnote.ru' }
    it { expect(parser.extract_source('Описание с goldenwind.ucoz.org')).to eq 'http://goldenwind.ucoz.org' }
    it { expect(parser.extract_source('bla-bla-bla')).to be_nil }
    it { expect(parser.extract_source('Описание взято с сайта eden404.ru')).to eq 'http://eden404.ru' }
    it { expect(parser.extract_source('Описание взято с сайта переводчиков insomniateam.ru')).to eq 'http://insomniateam.ru' }
  end

  describe 'fetches entry' do
    it 'common entry' do
      entry = parser.fetch_entry('hibiutsuroi')

      expect(entry[:id]).to eq 'hibiutsuroi'
      expect(entry[:names]).to eq ['День за днем, за годом год', 'Hibiutsuroi']
      expect(entry[:russian]).to eq 'День за днем, за годом год'
      expect(entry[:description]).to eq 'Как же весело и легко играть вместе в детстве! Совершенно не важно кто мальчик, а кто девочка. И как же всё становится непросто, когда подросший мальчик понимает, что его подружка не просто партнер по играм, а ДЕВОЧКА!'
      expect(entry[:source]).to eq 'http://animanga.ru'
      expect(entry[:score]).to eq 9.32
      expect(entry[:kind]).to eq :one_shot
      expect(entry[:read_first_url]).to eq '/hibiutsuroi/vol0/0?mature=1'
    end

    it 'w/o source' do
      entry = parser.fetch_entry('chihaya_full')

      expect(entry[:id]).to eq 'chihaya_full'
      expect(entry[:names]).to eq ['Яркая Чихая', 'Chihaya Full', 'Chihayafuru']
      expect(entry[:russian]).to eq 'Яркая Чихая'
      expect(entry[:description]).to eq "Всю свою жизнь Чихая мечтала о том, что ее сестра станет лучшей моделью Японии, пока молчаливый и неприметный Арата – новенький в их классе – не заставил ее понять, что присвоенную мечту нельзя назвать своей и над ее осуществлением нужно трудиться.\nАрата играет в традиционную японскую карточную игру по мотивам «Песен ста поэтов», и его игра захватывает Чихаю. Сыграв с ним, Чихая понимает, что нашла свое собственное увлечение. Теперь она хочет стать лучшим игроком в мире, Королевой Каруты."
      expect(entry[:source]).to eq 'http://readmanga.ru/chihaya_full'
      expect(entry[:score]).to eq 9.72
      expect(entry[:kind]).to eq :manga
    end

    it 'with linked source' do
      entry = parser.fetch_entry('home_tutor_hitman_reborn')

      expect(entry[:id]).to eq 'home_tutor_hitman_reborn'
      expect(entry[:names]).to eq ['Учитель мафиози Реборн', 'Home Tutor Hitman Reborn!', 'Katekyo Hitman Reborn!']
      expect(entry[:russian]).to eq 'Учитель мафиози Реборн'
      expect(entry[:description]).to eq "Тсунаёши Савада— на первый взгляд самый обыкновенный мальчик. Слегка невезуч, слегка неуклюж, слегка паникёр. Хотя, может, и не слегка. И все в его жизни скучно и безрадостно, до того волшебного момента, как пред его взором предстаёт чудо-ребёнок Реборн, который на деле оказывается давно зарекомендовавшим себя в мафиозном мире киллером. Реборн мило радует Тсуну, что отныне тот назначается наследником крупнейшей мафиозной семьи Вонгола, и что он, Реборн, обязуется сделать из него надлежащего босса. С этого дня жизнь Савады кардинально меняется..."
      expect(entry[:source]).to eq 'http://readmanga.ru/home_tutor_hitman_reborn'
      expect(entry[:score]).to eq 9.24
      expect(entry[:kind]).to eq :manga
      expect(entry[:read_first_url]).to eq '/home_tutor_hitman_reborn/vol0/0?mature=1'
    end

    it 'with domain source' do
      entry = parser.fetch_entry('the_magician_s_bride')

      expect(entry[:id]).to eq 'the_magician_s_bride'
      expect(entry[:names]).to eq ['Невеста чародея', "The Magician's Bride", 'Mahou Tsukai no Yome']
      expect(entry[:russian]).to eq 'Невеста чародея'
      expect(entry[:description]).to eq 'Хатори Тисэ только 16, но она уже пережила все тяготы жизни. У нее нет никого, а жизнь же ее не имеет никакого смысла. Но внезапно, уже успевшие заржаветь шестерёнки судьбы начинают двигаться. В тяжелый для нее момент таинственный маг предложил ей помощь, от которой она не могла отказаться. Но кто же он? Он похож скорее на демона чем на человека. Поможет ли он ей, или же ввергнет в пучины тьмы?'
      expect(entry[:source]).to eq 'http://eden404.ru'
      expect(entry[:score]).to eq 9.75
      expect(entry[:kind]).to eq :manga
      expect(entry[:read_first_url]).to eq '/the_magician_s_bride/vol1/1?mature=1'
    end


    it 'w/o russian' do
      entry = parser.fetch_entry 'trinity_blood_rage_against_the_moons'

      expect(entry[:id]).to eq 'trinity_blood_rage_against_the_moons'
      expect(entry[:kind]).to eq :one_shot
      expect(entry[:names]).to eq ['Trinity Blood Rage Against the Moons']
      expect(entry[:russian]).to eq 'Trinity Blood Rage Against the Moons'
      expect(entry[:description]).to eq 'Красивые иллюстрации к роману, выполненные THORES Shibamoto.'
      expect(entry[:score]).to eq 9.18
      expect(entry[:source]).to eq 'http://readmanga.ru/trinity_blood_rage_against_the_moons'
    end
  end

  it 'fetch entries' do
    entries = ['rosario_to_vampire', 'crepuscule__yamchi', 'corpse_demon', 'scarlet_prince', 'zero_sum_original_antology_series_arcana']

    expect(parser).to receive(:fetch_entry).exactly(entries.size).times
    expect(parser.fetch_entries(entries).size).to eq(entries.size)
  end

  it 'fetch pages' do
    allow(parser).to receive(:fetch_entry).and_return id: true
    items = parser.fetch_pages(0..2)
    expect(items.size).to be >= ReadMangaParser::PageSize * 3-1
  end
end
