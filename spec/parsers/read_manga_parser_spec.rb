describe ReadMangaParser do
  before { allow(SiteParserWithCache).to receive(:load_cache).and_return entries: {} }
  before { allow(SiteParserWithCache).to receive :save_cache }

  let(:parser) { ReadMangaParser.new }

  it { expect(parser.fetch_pages_num).to eq 75 }
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
  end

  describe 'fetches entry' do
    it 'common entry' do
      expect(parser.fetch_entry('hibiutsuroi')).to eq({
        id: 'hibiutsuroi',
        names: ['День за днем, за годом год', 'Hibiutsuroi'],
        russian: 'День за днем, за годом год',
        description: 'Как же весело и легко играть вместе в детстве! Совершенно не важно кто мальчик, а кто девочка. И как же всё становится непросто, когда подросший мальчик понимает, что его подружка не просто партнер по играм, а ДЕВОЧКА!',
        source: 'http://animanga.ru',
        score: 9.36,
        kind: 'One Shot',
        read_first_url: '/hibiutsuroi/vol0/0?mature=1',
      })
    end

    it 'w/o source' do
      parser.fetch_entry('chihaya_full') == {
        id: 'chihaya_full',
        names: ["Яркая Чихая", "Chihaya Full", "Chihayafuru"],
        russian: 'Яркая Чихая',
        description: "Всю свою жизнь Чихая мечтала о том, что ее сестра станет лучшей моделью Японии, пока молчаливый и неприметный Арата – новенький в их классе – не заставил ее понять, что присвоенную мечту нельзя назвать своей и над ее осуществлением нужно трудиться.\nАрата играет в традиционную японскую карточную игру по мотивам «Песен ста поэтов», и его игра захватывает Чихаю. Сыграв с ним, Чихая понимает, что нашла свое собственное увлечение. Теперь она хочет стать лучшим игроком в мире, Королевой Каруты.",
        source: 'http://readmanga.ru/chihaya_full',
        score: 9.71,
        kind: 'Manga'
      }
    end

    it 'with linked source' do
      expect(parser.fetch_entry('home_tutor_hitman_reborn')).to eq({
        id: 'home_tutor_hitman_reborn',
        names: ["Учитель мафиози Реборн", "Home Tutor Hitman Reborn!", "Katekyo Hitman Reborn!"],
        russian: 'Учитель мафиози Реборн',
        description: "Савада Тсунаёши — на первый взгляд самый обыкновенный мальчик. Слегка невезуч, слегка неуклюж, слегка паникёр. Хотя, может, и не слегка. И все в его жизни скучно и безрадостно, до того волшебного момента, как пред его взором предстаёт чудо-ребёнок Реборн. Который на деле оказывается давно зарекомендовавшим себя в мафиозном мире киллером. Реборн мило радует Тсуну, что отныне тот назначается наследником крупнейшей мафиозной семьи Вонгола, и что он, Реборн, обязуется сделать из него надлежащего босса. С этого дня жизнь Савады кардинально меняется...",
        source: 'http://animanga.ru',
        score: 9.22,
        kind: 'Manga',
        read_first_url: '/home_tutor_hitman_reborn/vol0/0?mature=1',
      })
    end

    it 'w/o russian' do
      entry = parser.fetch_entry 'trinity_blood_rage_against_the_moons'
      expect(entry[:id]).to eq "trinity_blood_rage_against_the_moons"
      expect(entry[:kind]).to eq "One Shot"
      expect(entry[:names]).to eq ["Trinity Blood Rage Against the Moons"]
      expect(entry[:russian]).to eq "Trinity Blood Rage Against the Moons"
      expect(entry[:description]).to eq "Красивые иллюстрации к роману, выполненные THORES Shibamoto."
      expect(entry[:score]).to eq 9.19
      expect(entry[:source]).to eq "http://readmanga.ru/trinity_blood_rage_against_the_moons"
    end
  end

  it 'fetch entries' do
    entries = ['rosario_to_vampire', 'crepuscule__yamchi', 'corpse_demon', 'scarlet_prince', 'zero_sum_original_antology_series_arcana']

    expect(parser).to receive(:fetch_entry).exactly(entries.size).times

    expect(parser.fetch_entries(entries).size).to eq(entries.size)
  end

  it 'fetch pages' do
    allow(parser).to receive(:fetch_entry).and_return id: true

    items = nil
    expect {
      items = parser.fetch_pages(0..2)
    }.to change(parser.cache[:entries], :count).by(items)
    expect(items.size).to be >= ReadMangaParser::PageSize * 3-1
  end
end
