describe ReadMangaParser do
  before { SiteParserWithCache.stub(:load_cache).and_return entries: {} }
  before { SiteParserWithCache.stub :save_cache }

  let(:parser) { ReadMangaParser.new }

  it { parser.fetch_pages_num.should eq 75 }
  it { parser.fetch_page_links(0).should have(ReadMangaParser::PageSize).items }
  it { parser.fetch_page_links(parser.fetch_pages_num - 1).last.should eq 'wild_kiss' }

  describe 'cleanup description' do
    it { parser.normalize_line("Яяя\r\nыыы.\r\nЗзз").should eq "Яяя ыыы.\nЗзз" }
    it { parser.normalize_line("a  a").should eq "a a" }
    it { parser.normalize_line("a a").should eq "a a" }
  end

  describe 'extracts source' do
    it { parser.extract_source('Site.ru').should eq 'http://site.ru' }
    it { parser.extract_source('http://site.ru').should eq 'http://site.ru' }
    it { parser.extract_source('© Алексей Мелихов, World Art').should eq '© Алексей Мелихов, http://world-art.ru' }
    it { parser.extract_source('Espada Clan (c)').should eq ReadMangaImportData::MangaTeams['espada clan'] }
    it { parser.extract_source('Copyright © Nomad Team').should eq ReadMangaImportData::MangaTeams['nomad team'] }
    it { parser.extract_source('Взято с animeshare.su').should eq 'http://animeshare.su' }
    it { parser.extract_source('(взято с animeshare.su)').should eq 'http://animeshare.su' }
    it { parser.extract_source('Kair', 'url').should eq '© Kair, url' }
    it { parser.extract_source('Описание составлено: BlaBlaBla', 'url').should eq '© BlaBlaBla, url' }
    it { parser.extract_source('Death Note - Kira Revival Project').should eq 'http://deathnote.ru' }
    it { parser.extract_source('Описание с goldenwind.ucoz.org').should eq 'http://goldenwind.ucoz.org' }
    it { parser.extract_source('bla-bla-bla').should be_nil }
  end

  describe 'fetches entry' do
    it 'common entry' do
      parser.fetch_entry('hibiutsuroi').should == {
        id: 'hibiutsuroi',
        names: ['День за днем, за годом год', 'Hibiutsuroi'],
        russian: 'День за днем, за годом год',
        description: 'Как же весело и легко играть вместе в детстве! Совершенно не важно кто мальчик, а кто девочка. И как же всё становится непросто, когда подросший мальчик понимает, что его подружка не просто партнер по играм, а ДЕВОЧКА!',
        source: 'http://animanga.ru',
        score: 9.36,
        kind: 'One Shot',
        read_first_url: '/hibiutsuroi/vol0/0?mature=1',
      }
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
      parser.fetch_entry('home_tutor_hitman_reborn').should == {
        id: 'home_tutor_hitman_reborn',
        names: ["Учитель мафиози Реборн", "Home Tutor Hitman Reborn!", "Katekyo Hitman Reborn!"],
        russian: 'Учитель мафиози Реборн',
        description: "Савада Тсунаёши — на первый взгляд самый обыкновенный мальчик. Слегка невезуч, слегка неуклюж, слегка паникёр. Хотя, может, и не слегка. И все в его жизни скучно и безрадостно, до того волшебного момента, как пред его взором предстаёт чудо-ребёнок Реборн. Который на деле оказывается давно зарекомендовавшим себя в мафиозном мире киллером. Реборн мило радует Тсуну, что отныне тот назначается наследником крупнейшей мафиозной семьи Вонгола, и что он, Реборн, обязуется сделать из него надлежащего босса. С этого дня жизнь Савады кардинально меняется...",
        source: 'http://animanga.ru',
        score: 9.22,
        kind: 'Manga',
        read_first_url: '/home_tutor_hitman_reborn/vol0/0?mature=1',
      }
    end

    it 'w/o russian' do
      entry = parser.fetch_entry 'trinity_blood_rage_against_the_moons'
      entry[:id].should eq "trinity_blood_rage_against_the_moons"
      entry[:kind].should eq "One Shot"
      entry[:names].should eq ["Trinity Blood Rage Against the Moons"]
      entry[:russian].should eq "Trinity Blood Rage Against the Moons"
      entry[:description].should eq "Красивые иллюстрации к роману, выполненные THORES Shibamoto."
      entry[:score].should eq 9.19
      entry[:source].should eq "http://readmanga.ru/trinity_blood_rage_against_the_moons"
    end
  end

  it 'fetch entries' do
    entries = ['rosario_to_vampire', 'crepuscule__yamchi', 'corpse_demon', 'scarlet_prince', 'zero_sum_original_antology_series_arcana']

    parser.should_receive(:fetch_entry).exactly(entries.size).times

    parser.fetch_entries(entries).should have(entries.size).items
  end

  it 'fetch pages' do
    parser.stub(:fetch_entry).and_return id: true

    items = nil
    expect {
      items = parser.fetch_pages(0..2)
    }.to change(parser.cache[:entries], :count).by(items)
    items.should have_at_least(ReadMangaParser::PageSize * 3-1).items
  end
end
