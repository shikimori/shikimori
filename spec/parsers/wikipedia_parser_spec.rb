describe WikipediaParser, vcr: { cassette_name: 'wikipedia' } do
  before { allow(WikipediaParser).to receive(:load_cache).and_return(animes: {}, characters: {}) }
  before { allow(parser).to receive :save_cache }

  let(:parser) { WikipediaParser.new }
  let(:zero_no_tsukaima) do
    create :anime,
      name: 'Zero no Tsukaima',
      synonyms: ["Zero's Familiar"],
      english: ['The Familiar of Zero'],
      russian: ''
  end
  let(:toradora) { create :anime, name: 'Toradora!', russian: '' }
  let(:bleach) { create :anime, name: 'Bleach', russian: 'Блич' }
  let(:is) { create :anime, name: 'IS: Infinite Stratos', russian: '' }

  it 'fetches pages from wikipedia' do
    data = parser.fetch_pages([zero_no_tsukaima.name.tr(' ', '_')])

    expect(data.size).to eq(1)
    expect(data[0][1].length).to be > 14000
  end

  it 'fetches additional sources' do
    expect(parser.fetch_anime(bleach).size).to eq(2)
  end

  it 'follows redirect while fetching page from wikipedia' do
    data = parser.fetch_pages([toradora.name])
    expect(data.size).to eq(1)
    expect(data[0][1].length).to be > 14000
  end

  it 'replaces name with brackets' do
    expect(parser.fetch_anime(is).size).to eq(1)
  end

  describe 'cleanup_wikitext' do
    it '—' do
      expect(parser.cleanup_wikitext('—')).to eq '-'
    end

    it '* Сэйю: blablabla\\n' do
      expect(parser.cleanup_wikitext("* Сэйю: blablabla\n")).to be_empty
    end

    it "''' Сэйю '''" do
      expect(parser.cleanup_wikitext("\n'''[[Сэйю]]:''' {{нл|Мэгуми|Тоёгути}}.\n")).to eq "\n"
      expect(parser.cleanup_wikitext("\n* '''[[Сэйю]]:''' {{нл|Мэгуми|Тоёгути}}.\n")).to eq "\n"
    end

    it ': [[Сэйю]] — {{nl|Хирофумо|Нодзима}}.' do
      expect(parser.cleanup_wikitext(': [[Сэйю]] — {{nl|Хирофумо|Нодзима}}.')).to be_empty
    end

    it ': [[Сэйю]]: [[Косимидзу Ами]]\n' do
      expect(parser.cleanup_wikitext(": [[Сэйю]]: [[Косимидзу Ами]]\n")).to be_empty
    end

    it ': [[Сэйю]]: [[Косимидзу Ами]];' do
      expect(parser.cleanup_wikitext(': [[Сэйю]]: [[Косимидзу Ами]];')).to be_empty
    end

    it 'Сэйю — {{nl|Мисудзу|Тогаси}}.' do
      expect(parser.cleanup_wikitext('Сэйю — {{nl|Мисудзу|Тогаси}}.')).to be_empty
    end

    it '* [[Файл:Chara 02.jpg|thumb|Сиэль Фантомхайв]]' do
      expect(parser.cleanup_wikitext('* [[Файл:Chara 02.jpg|thumb|Сиэль Фантомхайв]]')).to eq '* '
    end

    it '[[файл:Chara 02.jpg|thumb|[[Сиэль Фантомхайв]]]]' do
      expect(parser.cleanup_wikitext('[[файл:Chara 02.jpg|thumb|[[Сиэль Фантомхайв]]]]')).to be_empty
    end

    it 'source' do
      expect(parser.cleanup_wikitext('{{Источник:Блич|1|7|173}}')).to be_empty
      expect(parser.cleanup_wikitext('{{Source:Блич|1|7|173}}')).to be_empty
    end

    it 'comments' do
      expect(parser.cleanup_wikitext("&lt;!-- Имя написано согласно правилам чтения японских слов!-->\n")).to be_empty
      expect(parser.cleanup_wikitext("&lt;!-- Имя написано согласно правилам чтения японских слов-->\n")).to be_empty
    end

    it 'single refs' do
      expect(parser.cleanup_wikitext('<ref xzxcvxcv/>test<ref zxczxc>zxc</ref>aa')).to eq 'testaa'
    end

    it '[[wiktionary:茶|茶]]' do
      expect(parser.cleanup_wikitext('[[wiktionary:茶|茶]]')).to eq '茶'
    end

    it '{{нп3|Каго,_Ай|Ай Каго||Ai Kago}}' do
      expect(parser.cleanup_wikitext('{{нп3|Каго,_Ай|Ай Каго||Ai Kago}}')).to eq 'Ai Kago'
    end

    it 'refs' do
      expect(parser.cleanup_wikitext('<ref xzxcvxcv>test</ref>tqqqw&lt;ref fdsdf>&lt;/ref>')).to eq 'tqqqw'
    end

    it 'nl' do
      expect(parser.cleanup_wikitext('{{nl|zxc|cvb}}')).to eq 'cvb'
      expect(parser.cleanup_wikitext('{{nl|cvb}}')).to eq 'cvb'
    end

    it 'что?' do
      expect(parser.cleanup_wikitext('{{что?}}')).to be_empty
    end

    it '{{disambig}}' do
      expect(parser.cleanup_wikitext('{{disambig}}')).to be_empty
    end

    it '<center>' do
      expect(parser.cleanup_wikitext('&lt;center>test&lt;/center>')).to eq '<center>test</center>'
    end

    it '<br>' do
      expect(parser.cleanup_wikitext('<br>')).to eq "\n"
      expect(parser.cleanup_wikitext('<br >')).to eq "\n"
      expect(parser.cleanup_wikitext('<br/>')).to eq "\n"
      expect(parser.cleanup_wikitext('<br />')).to eq "\n"
      expect(parser.cleanup_wikitext('&lt;br />')).to eq "\n"
    end

    it '<br clear="left">' do
      expect(parser.cleanup_wikitext('<br clear="left">')).to eq "\n"
      expect(parser.cleanup_wikitext('<br clear="left" >')).to eq "\n"
      expect(parser.cleanup_wikitext('<br clear=left>')).to eq "\n"
      expect(parser.cleanup_wikitext("<br clear=\"left\" \>")).to eq "\n"
      expect(parser.cleanup_wikitext('&lt;br clear="left">')).to eq "\n"
    end

    # it '{{Китайский||李盖梅||Ли Гаймэй}}' do
      # parser.cleanup_wikitext("{{Китайский||李盖梅||Ли Гаймэй}}").should eq 'Ли Гаймэl (李盖梅)'
    # end

    it '{{не переведено|есть=:en:ofuda|надо=офуда|текст=|язык=en|nocat=1}}' do
      expect(parser.cleanup_wikitext('{{не переведено|есть=:en:ofuda|надо=офуда|текст=|язык=en|nocat=1}}')).to eq 'офуда'
    end

    it '{{who}}' do
      expect(parser.cleanup_wikitext('{{who}}')).to be_empty
    end

    it '{{who?}}' do
      expect(parser.cleanup_wikitext('{{who?}}')).to be_empty
    end

    it '{{кто}}' do
      expect(parser.cleanup_wikitext('{{кто}}')).to be_empty
    end

    it '{{кто?}}' do
      expect(parser.cleanup_wikitext('{{кто?}}')).to be_empty
    end

    it '{{Abbr|SSTV|Station Square Television|0}}' do
      expect(parser.cleanup_wikitext('{{Abbr|SSTV|Station Square Television|0}}')).to eq 'SSTV'
    end

    it '{{Abbr|SSTV}}' do
      expect(parser.cleanup_wikitext('{{Abbr|SSTV}}')).to eq 'SSTV'
    end

    it '{{чего}}' do
      expect(parser.cleanup_wikitext('{{чего}}')).to be_empty
    end

    it '{{что}}' do
      expect(parser.cleanup_wikitext('{{что}}')).to be_empty
    end

    it '{{cite web |.*}}' do
      expect(parser.cleanup_wikitext('{{cite web |url = http://www.animenewsnetwork.com/critique/death-note/dvd-7 |title = Death Note DVD 7 |author = Theron Martin |date = 2009.02.09 |work = [[AnimeNewsNetwork]] |publisher =  |accessdate = 2012-04-22 |lang = en}}')).to be_empty
    end

    it '{{Переход|#Марс в античной мифологии|green}}' do
      expect(parser.cleanup_wikitext('{{Переход|#Марс в античной мифологии|green}}')).to be_empty
    end

    it '{{цитата|Ха! Я придумал слово невозможно. Вот почему я чемпион. Нравится ли мне это или нет}}' do
      expect(parser.cleanup_wikitext('{{цитата|Ха! Я придумал слово невозможно. Вот почему я чемпион. Нравится ли мне это или нет}}')).to eq '[quote]Ха! Я придумал слово невозможно. Вот почему я чемпион. Нравится ли мне это или нет[/quote]'
    end

    it '{{vgy|zxc|cvb}}' do
      expect(parser.cleanup_wikitext('{{vgy|zxc|cvb}}')).to eq 'cvb'
      expect(parser.cleanup_wikitext('{{vgy|cvb}}')).to eq 'cvb'
    end

    it '{{nobr|test test}}' do
      expect(parser.cleanup_wikitext('{{nobr|test test}}')).to eq 'test test'
    end

    it '{{хангыль|Им Ёнсу|임용수|Im Yong Soo|также {{イ・ヨンス}}}}' do
      expect(parser.cleanup_wikitext('{{хангыль|Им Ёнсу|임용수|Im Yong Soo|также {{イ・ヨンス}}}}')).to eq 'Им Ёнсу'
    end

    it '{{anime voice}}' do
      expect(parser.cleanup_wikitext("\n: {{anime voice}} tstebc")).to be_empty
      expect(parser.cleanup_wikitext('{{anime voice}}')).to be_empty
    end

    it '{{anchor|test}}' do
      expect(parser.cleanup_wikitext('{{anchor|test}}')).to be_empty
      expect(parser.cleanup_wikitext('{{якорь|test}}')).to be_empty
    end

    it '{{уточнить}}' do
      expect(parser.cleanup_wikitext('{{уточнить}}')).to be_empty
    end

    it '{{Китайский|[臧]春麗|[臧]春丽|Chūnlì}}' do
      expect(parser.cleanup_wikitext('{{Китайский|[臧]春麗|[臧]春丽|Chūnlì}}')).to eq '[臧]春麗'
    end

    it '{{ref|J210|гл.210}}' do
      expect(parser.cleanup_wikitext('{{ref|J210|гл.210}}')).to be_empty
    end

    it '{{нет АИ|15|09|2011}}' do
      expect(parser.cleanup_wikitext('{{нет АИ|15|09|2011}}')).to be_empty
      expect(parser.cleanup_wikitext('{{Нет АИ|15|09|2011}}')).to be_empty
    end

    it '{{Кратко о персонаже}}' do
      expect(parser.cleanup_wikitext("{{Кратко о персонаже|\n| ааа   = 123\n| ббб=456\n}}")).to eq "** Ааа: 123\n** Ббб: 456\n"
    end

    it '{{Персонаж аниме/манги}}' do
      expect(parser.cleanup_wikitext("{{Персонаж аниме/манги\n| ааа   = 123\n| ббб=456\n}}")).to eq "** Ааа: 123\n** Ббб: 456\n"
    end

    it 'two {{Персонаж аниме/манги}}' do
      expect(parser.cleanup_wikitext("{{Персонаж аниме/манги\n| ааа   = 123\n| ббб=456\n}}\nzxc\n{{Персонаж аниме/манги\n| ааа   = 123\n| ббб=456\n}}")).to eq "** Ааа: 123\n** Ббб: 456\n\nzxc\n** Ааа: 123\n** Ббб: 456\n"
    end

    it '{{ options }} {{Персонаж аниме/манги}}' do
      expect(parser.cleanup_wikitext("{{Персонаж аниме/манги\n| ааа   = {{123}}\n| {{ббб}}=456\n}}")).to eq "** Ааа: {{123}}\n** {{ббб}}: 456\n"
    end

    it 'empty options in {{Персонаж аниме/манги}}' do
      expect(parser.cleanup_wikitext("{{Персонаж аниме/манги\n| ааа   = 123\n| ббб=456\n| ссс   = \n}}")).to eq "** Ааа: 123\n** Ббб: 456\n"
    end

    it 'forbidden options in {{Персонаж аниме/манги}}' do
      expect(parser.cleanup_wikitext("{{Персонаж аниме/манги\n | ааа   = 123\n| ббб=456\n| цвет   = 123\n| имя=456\n}}")).to eq "** Ааа: 123\n** Ббб: 456\n"
    end

    it 'long {{Персонаж аниме/манги}}' do
      expect(parser.cleanup_wikitext("==== Дзирайя ====
{{Персонаж аниме/манги
|цвет =#F5DEB3
|имя =Дзирайя
|изображение =
|первое =Манга: 90 глава <br />Аниме: I часть 52 серия
|сэйю ={{nl|Ёситада|Оцука}} ([[:en:Hōchū Ōtsuka|англ.]]) <br />{{nl|Тору|Нара}} ([[:en:Toru Nara|англ.]]) (в молодости)
|прозвище =Извращённый отшельник, <br />Жабий отшельник
|возраст =I ч. — 50-51 лет <br />II ч. — 54 лет (убит)
|родился =11 ноября
|рост =191,2 см
|вес =87,5 кг
|звание =[[Мир Наруто#Саннин|Саннин]]
|формирование ='''Команда Сарутоби''' ([[Третий Хокагэ]], [[Оротимару (Наруто)|Оротимару]], Дзирайя, [[Цунадэ (Наруто)|Цунадэ]]) <br /> '''Команда Дзирайи''' (Дзирайя, [[Четвёртый Хокагэ|Минато Намикадзэ]], два неизвестных гэнина)
|родственники =
}}
{{нихонго|'''Дзирайя'''|自来也}} — один из основных персонажей «Наруто», учитель [[Наруто Удзумаки|главного героя]].
[[Кандзи]] на его головной повязке означает {{нихонго|«масло»|油|абура}}, что, возможно, подразумевает использование им жабьего масла в
медицинских целях или в комбинированной атаке с жабами.")).to include(
  "==== Дзирайя ====\n** Появление: Манга: 90 глава, Аниме: I часть 52 серия\n** Возраст: I ч. - 50-51 лет, II ч. - 54 лет (убит)\n"
)
    end

    it '{{Смотри также...}}' do
      expect(parser.cleanup_wikitext('{{Смотри также|Список серий Naruto:  1-4)|Списо 5-8)|Список сери 9-12)}}')).to be_empty
    end

    it '<gallery>' do
      expect(parser.cleanup_wikitext("<gallery perrow=\"5\" width=\"90%\">
<!-- Порядок дан по алфавиту-->
Файл:Kazekage hat (Naruto, manga).svg|Головной убор <!--Не изменяйте, всё правильно! См. страницу обсуждения этой статьи!-->Кадзэкагэ
Файл:Mizukage hat (Naruto, manga).svg|Головной убор <!--Не изменяйте, всё правильно! См. страницу обсуждения этой статьи!-->Мидзукагэ
Файл:Raikage hat (Naruto, manga).svg|Головной убор Райкагэ
Файл:Chapeau Hiruzen Sarutobi.svg|Головной убор Хокагэ
Файл:Tsuchikage hat (Naruto, manga).svg|Головной убор Цутикагэ
</gallery>")).to be_empty
    end

    it 'quotes' do
      expect(parser.cleanup_wikitext("{{начало цитаты}}zxc\n{{конец цитаты|источник=«Noein»}}")).to be_empty
    end
  end

  describe 'cleanup_description' do
    it '^:' do
      expect(parser.cleanup_description(': ', russian: '')).to be_empty
    end

    it '^*' do
      expect(parser.cleanup_description('* ', russian: '')).to be_empty
    end

    it '- bla' do
      expect(parser.cleanup_description('- bla', russian: '')).to eq 'Bla'
      expect(parser.cleanup_description(', bla', russian: '')).to eq 'Bla'
    end

    it 'nihongo' do
      expect(parser.cleanup_description("{{nihongo|'''Иссин Куросаки'''|黒崎 一心|Куросаки Иссин|''Kurosaki Isshin''}}", russian: '')).to eq 'Иссин Куросаки'
    end

    it 'nihongo with notice' do
      expect(parser.cleanup_description('{{Нихонго|Мессер|メッサー|мэсса:|{{lang-de|Messer}} — «нож»}}', russian: '')).to eq 'Мессер'
    end

    it "'''" do
      expect(parser.cleanup_description("'''Иссин Куросаки'''", russian: '')).to eq 'Иссин Куросаки'
    end

    it "''" do
      expect(parser.cleanup_description("''Иссин Куросаки''", russian: '')).to eq 'Иссин Куросаки'
    end

    it '{{lang' do
      expect(parser.cleanup_description('{{lang-ja2|Engetsu}}', russian: '')).to eq 'Engetsu'
    end

    it 'name in the beginning' do
      expect(parser.cleanup_description('Иссин Куросаки - test', russian: 'Иссин Куросаки')).to eq 'Test'
      expect(parser.cleanup_description('Иссин Куросаки — test', russian: 'Иссин Куросаки')).to eq 'Test'
      expect(parser.cleanup_description('Иссин Куросаки, test', russian: 'Иссин Куросаки')).to eq 'Test'
      expect(parser.cleanup_description("{{нихонго|''XXX''|test}} <br />\n test", russian: 'XXX')).to eq 'Test'
      expect(parser.cleanup_description("Иссин Куросаки <br />\n test", russian: 'Иссин Куросаки')).to eq 'Test'
      expect(parser.cleanup_description("Иссин Куросаки \n test", russian: 'Иссин Куросаки')).to eq 'Test'
    end

    it 'first symbol uppercased' do
      expect(parser.cleanup_description('иссин', russian: '')).to eq 'Иссин'
    end

    it 'list in the beginning' do
      expect(parser.cleanup_description("\n: ZXC\n: CCC", russian: '')).to eq "[list]\n[*] ZXC\n[*] CCC\n[/list]"
    end

    it 'process list in any part' do
      expect(parser.cleanup_description("test\n: ZXC\n: CCC", russian: '')).to eq "Test\n[list]\n[*] ZXC\n[*] CCC\n[/list]"
    end

    it 'Seyu in the beginnig' do
      expect(parser.cleanup_description("* Сэйю — {{nl|Дзюн|Фукуяма}} (Период детства озвучивает {{nl|Саяка|Охара}})\nTest", russian: '')).to eq 'Test'
      expect(parser.cleanup_description("[*] Сэйю — {{nl|Дзюн|Фукуяма}} (Период детства озвучивает {{nl|Саяка|Охара}})\nTest", russian: '')).to eq 'Test'
    end

    it '{{main}}' do
      expect(parser.cleanup_description('{{main|test}}', russian: '')).to be_empty
    end

    it '<center>' do
      expect(parser.cleanup_description('<center>test</center>', russian: '')).to eq '[b]test[/b]'
    end
  end

  describe 'characters extraction' do
    describe 'default' do
      it '{{Опсание персонажа}}' do
        expect(parser.extract_default("
{{Описание персонажа
  | имя      = Аква
  | кандзи   = アクア
  | киридзи  = Акуа
  | описание = DESCRIPTION
  | сэйю     = {{nl|Мэгуми|Тоёгути}}
}}")).to eq [{ russian: 'Аква', japanese: 'アクア', description_ru: 'DESCRIPTION' }]
      end

      it 'extracts full name' do
        expect(parser.extract_default("
{{Описание персонажа
 | имя      = Луиза (полное имя Кирхе [[Екатерина II|Луиза Фредерика фон Анхальт-Цербст]])
 | описание = DESCRIPTION
 | сэйю     = {{nl|Нанако|Иноуэ}}
}}")).to eq [{ russian: 'Луиза Фредерика фон Анхальт-Цербст', japanese: nil, description_ru: 'DESCRIPTION' }]
      end
    end

    describe 'old default' do
      it 'detailed data' do
        expect(parser.extract_default_old("«Блич»|проводников душ]]», воинов, которые защищают людей, сражаясь со злыми духами [[Пустые (Bleach)|пустыми]], и помогают добрым душам уйти в [[Загробный мир|мир иной]].
  : [[Сэйю]] — {{nl|Масакадзу|Морита}}.

  === Рукия Кучики ===
  {{main|Рукия Кучики}}
  Рукия Кучики — девушка-проводник душ, которая была отправлена патрулировать родной город Ичиго и защищать жителей от пустых, а также отправлять души умерших в [[Блич#Мир|Сообщество душ]] ([[загробный мир]]), совершая обряд {{nihongo|погребения души|魂葬|консо:}}. Несмотря на то что она выглядит, как [[подросток]], ей в действительности более 150-ти лет. По ряду обстоятельств Рукия вынуждена передать свою духовную энергию Ичиго и вести жизнь обычного человека, находясь в гигае («временном теле»), которое проводники душ используют в экстренных ситуациях.{{Источник:Блич|1|2|71}} После утраты сил она способна лишь на мелкие заклинания.{{Источник:Блич|1|2|70}} Рукии нравится жить в мире людей, она обладает странноватым чувством юмора и сварливым характером, любит объяснять всё в виде собственноручно нарисованных [[комикс]]ов. Рукия является первым персонажем, придуманным автором.<ref name=\"About 1\">{{cite web|url= http://manga.about.com/od/mangaartistinterviews/a/TiteKubo.htm |title= Interview: Tite Kubo (стр. 1)|author=Дэб Аоки. |publisher=[[About.com]] |lang = en| accessdate= 2008-09-25}}</ref>
  : [[Сэйю]] — {{nl|Фумико|Орикаса}}.
  === Орихимэ Иноуэ ===", WikipediaParser::CharacterDetailedRegexp)).to eq [{
    russian: 'Рукия Кучики',
    description_ru: 'Девушка-проводник душ, которая была отправлена патрулировать родной город Ичиго и защищать жителей от пустых, а также отправлять души умерших в [[Блич#Мир|Сообщество душ]] ([[загробный мир]]), совершая обряд погребения души. Несмотря на то что она выглядит, как [[подросток]], ей в действительности более 150-ти лет. По ряду обстоятельств Рукия вынуждена передать свою духовную энергию Ичиго и вести жизнь обычного человека, находясь в гигае («временном теле»), которое проводники душ используют в экстренных ситуациях. После утраты сил она способна лишь на мелкие заклинания. Рукии нравится жить в мире людей, она обладает странноватым чувством юмора и сварливым характером, любит объяснять всё в виде собственноручно нарисованных [[комикс]]ов. Рукия является первым персонажем, придуманным автором.'
  }]
      end

      it 'common data' do
        expect(parser.extract_default_old("\n* {{Нихонго-но-намаэ|'''Карин Куросаки'''|黒崎 夏梨}} — дочь Иссина, сестра-[[близнец]] Юдзу, младше Ичиго на четыре года.",
          WikipediaParser::CharacterDetailedRegexp)).to eq [{
            russian: 'Карин Куросаки',
            japanese: '黒崎 夏梨',
            description_ru: 'Дочь Иссина, сестра-[[близнец]] Юдзу, младше Ичиго на четыре года.'
          }]
      end

      it 'common data with \[\[ \]\]' do
        expect(parser.extract_default_old("\n* {{Нихонго-но-намаэ|\[\[Карин Куросаки#Карин Куросаки|Test\]\]|黒崎 夏梨}} — Zzz.",
          WikipediaParser::CharacterDetailedRegexp)).to eq [{
            russian: 'Test',
            japanese: '黒崎 夏梨',
            description_ru: 'Zzz.'
          }]
      end

      it 'common data with english name tag' do
        expect(parser.extract_default_old("\n: {{Нихонго-но-намаэ|'''Карин Куросаки'''|黒崎 夏梨|Куросаки Карин|''Kurosaki Karin''}} — дочь Иссина, сестра-[[близнец]] Юдзу, младше Ичиго на четыре года.",
          WikipediaParser::CharacterDetailedRegexp)).to eq [{
            russian: 'Карин Куросаки',
            japanese: '黒崎 夏梨',
            english: 'Kurosaki Karin',
            description_ru: 'Дочь Иссина, сестра-[[близнец]] Юдзу, младше Ичиго на четыре года.'
          }]
      end

      it 'common data with additional {{ tag }}' do
        expect(parser.extract_default_old("\n{{Нихонго-но-намаэ|'''Карин Куросаки'''|黒崎 夏梨|{{lang-en|Love}} — «любовь»}} — дочь Иссина, сестра-[[близнец]] Юдзу, младше Ичиго на четыре года.",
          WikipediaParser::CharacterDetailedRegexp)).to eq [{
            russian: 'Карин Куросаки',
            japanese: '黒崎 夏梨',
            english: 'Love',
            description_ru: 'Дочь Иссина, сестра-[[близнец]] Юдзу, младше Ичиго на четыре года.'
          }]
      end

      it "'''name'''" do
        expect(parser.extract_default_old("\n'''Луиза''' ({{lang-en|Louise}}, {{lang-ja|ルイズ}} ''Руидзу'')\n\nЛуиза — главная героиня",
          WikipediaParser::CharacterDetailedRegexp)).to eq [{
            russian: 'Луиза',
            japanese: 'ルイズ',
            english: 'Louise',
            description_ru: 'Главная героиня'
          }]
      end

      it 'data with name in square brackets' do
        expect(parser.extract_default_old("\n{{нихонго|[[Лелуш Ламперуж]]|ルルーシュ・ランペルージ|Руру:сю Рампэру:дзи}}\nTest",
          WikipediaParser::CharacterDetailedRegexp)).to eq [{
            russian: 'Лелуш Ламперуж',
            japanese: 'ルルーシュ・ランペルージ',
            description_ru: 'Test'
          }]
      end

      it 'list after name block' do
        expect(parser.extract_default_old("\n{{нихонго|[[Лелуш Ламперуж]]|ルルーシュ・ランペルージ|Руру:сю Рампэру:дзи}}\n: '''Возраст:''' I арка — 17 лет, II арка — 18 лет\n: '''Национальность''' — британец\nTest",
          WikipediaParser::CharacterDetailedRegexp)).to eq [{
            russian: 'Лелуш Ламперуж',
            japanese: 'ルルーシュ・ランペルージ',
            description_ru: "[list]\n[*] Возраст: I арка - 17 лет, II арка - 18 лет\n[*] Национальность - британец\n[/list]\nTest"
          }]
      end

      it 'japanese name' do
        expect(parser.extract_default_old("\n{{нихонго|Чарльз ди Британия|シャルル・ジ・ブリタニア|Сяруру дзи Буританиа}}\nTest",
          WikipediaParser::CharacterDetailedRegexp)).to eq [{
            russian: 'Чарльз ди Британия',
            japanese: 'シャルル・ジ・ブリタニア',
            description_ru: 'Test'
          }]
      end

      it 'simple japanese name' do
        expect(parser.extract_default_old("\n{{нихонго|Нагато|永田}}\nTest",
          WikipediaParser::CharacterDetailedRegexp)).to eq [{
            russian: 'Нагато',
            japanese: '永田',
            description_ru: 'Test'
          }]
      end

      it 'colon in the beginning and seyu before' do
        expect(parser.extract_default_old("\n{{нихонго|Нагато|永田}}\n:Сэйю: [[Каори Надзука]]\n: Лучшая подружка Араси.",
          WikipediaParser::CharacterDetailedRegexp)).to eq [{
            russian: 'Нагато',
            japanese: '永田',
            description_ru: 'Лучшая подружка Араси.'
          }]
      end

      it 'with seyu' do
        expect(parser.extract_default_old("\n{{нихонго-но-намаэ|'''Симазаки'''|島崎|Симазаки|[[Сэйю]] — [[Риэ Танака]]}}\nTest",
          WikipediaParser::CharacterDetailedRegexp)).to eq [{
            russian: 'Симазаки',
            japanese: '島崎',
            description_ru: 'Test'
          }]
      end
    end

    describe 'by_header' do
      it 'common name' do
        expect(parser.extract_by_header("=== Ю Канда ===\n {{нихонго|'''Ю Канда'''|神田 ユウ|Канда Ю:}} — парень 18 лет, который имеет очень сложный характер.")).to eq [{
          russian: 'Ю Канда',
          japanese: '神田 ユウ',
          description_ru: 'Парень 18 лет, который имеет очень сложный характер.'
        }]
      end

      it "'''name'''" do
        expect(parser.extract_by_header("=== '''Ю Канда''' ===\n {{нихонго|'''Ю Канда'''|神田 ユウ|Канда Ю:}} — парень 18 лет, который имеет очень сложный характер.")).to eq [{
          russian: 'Ю Канда',
          japanese: '神田 ユウ',
          description_ru: 'Парень 18 лет, который имеет очень сложный характер.'
        }]
      end

      it '[[name]]' do
        expect(parser.extract_by_header("=== [[Ю Канда]] ===\n {{нихонго|'''Ю Канда'''|神田 ユウ|Канда Ю:}} — парень 18 лет, который имеет очень сложный характер.")).to eq [{
          russian: 'Ю Канда',
          japanese: '神田 ユウ',
          description_ru: 'Парень 18 лет, который имеет очень сложный характер.'
        }]
      end

      it 'separate line' do
        expect(parser.extract_by_header("=== Алма Карма ===
{{нихонго|''Алма Карма''|アルマ カルマ|Арума Карума}}
Алма Карма был единственным Вторым Экзорцистом, успешно созданным по Программе Искусственных Апостолов, за исключением Ю Канды.")).to eq [{
  russian: 'Алма Карма',
  japanese: 'アルマ カルマ',
  description_ru: 'Алма Карма был единственным Вторым Экзорцистом, успешно созданным по Программе Искусственных Апостолов, за исключением Ю Канды.'
}]
      end

      it 'extended header' do
        expect(parser.extract_by_header("=== Бак Чан ===
{{нихонго|''Бак Чан''|バク・チャン|Баку Тян}}, ({{Китайский||白灿||Бай Цань}}, в тайваньском переводе {{Китайский||莫·张||Мо ЧЖАН}} или {{Китайский||巴克·强||Бакэ ЦЯН}})
ZXC")).to eq [{
  russian: 'Бак Чан',
  japanese: 'バク・チャン',
  description_ru: 'ZXC'
}]
      end

      it 'extended header on one line' do
        expect(parser.extract_by_header("=== Комуи Ли ===
{{нихонго|''Комуи Ли''|コムイ・リー|Комуи Ри:}} ({{Китайский||李盖梅||Ли Гаймэй}}，''в тайваньском переводе'' 科穆伊·李 или 考姆伊) — старший брат Линали Ли.")).to eq [{
  russian: 'Комуи Ли',
  japanese: 'コムイ・リー',
  description_ru: 'Комуи Ли - старший брат Линали Ли.'
}]
      end

      it 'with list in the beginning' do
        expect(parser.extract_by_header("==== Бодзо ====\n: Возраст: неизвестен\n: Род занятий: маг\n{{nihongo|Бодзо|ボゾ}} — присутствует только в аниме.")).to eq [{
          russian: 'Бодзо',
          japanese: 'ボゾ',
          description_ru: "[list]\n[*] Возраст: неизвестен\n[*] Род занятий: маг\n[/list]\nПрисутствует только в аниме."
        }]
      end
    end
  end

  describe 'extract characters' do
    it 'Zero no Tsukaima' do
      chars = parser.extract_characters(zero_no_tsukaima)

      expect(chars.size).to eq(15)

      expect(chars.first[:russian]).to eq 'Луиза Франсуаза ле Блан де ла Вальер де Тристейн'
      expect(chars.first[:english]).to be_nil
      expect(chars.first[:japanese]).to be_nil

      expect(chars.last[:russian]).to eq 'Лонгвиль'
      expect(chars.last[:english]).to be_nil
      expect(chars.last[:japanese]).to be_nil
    end

    it 'Toradora!' do
      expect(parser.extract_characters(toradora).size).to be >= 5
    end

    it 'Spice and Wolf' do
      chars = parser.extract_characters(create :anime, name: 'Spice and Wolf')

      expect(chars.size).to be >= 4
      expect(chars[1][:russian]).to eq 'Крафт Лоуренс'
    end

    it 'Shiki' do
      expect(parser.extract_characters(create :anime, name: 'Shiki').size).to eq(11)
    end

    it 'Myself ; Yourself' do
      expect(parser.extract_characters(create :anime, name: 'Myself ; Yourself').size).to eq(8)
    end

    it 'Mirai Nikki' do
      chars = parser.extract_characters(create :anime, name: 'Mirai Nikki')

      expect(chars.find { |v| v[:russian].include? 'Deus' }[:japanese]).to eq 'デウス・エクス・マキナ'

      expect(chars.size).to eq(33)
      expect(chars.first[:russian]).to eq 'Юкитэру Амано'
      expect(chars.first[:japanese]).to eq '天野雪輝'
    end

    it 'Freezing' do
      expect(parser.extract_characters(create :anime, name: 'Freezing').size).to eq(25)
    end

    it 'Aria' do
      expect(parser.extract_characters(create :anime, name: 'Aria').size).to be >= 13
    end

    it 'Death Note' do
      expect(parser.extract_characters(create :anime, name: 'Death Note').size).to be >= 50
    end

    it 'Ah! My Goddess' do
      expect(parser.extract_characters(create :anime, name: 'Ah! My Goddess').size).to be >= 33
    end

    it 'Seitokai no Ichizon' do
      expect(parser.extract_characters(create :anime, name: 'Seitokai no Ichizon').size).to eq(5)
    end

    it 'Genshiken' do
      expect(parser.extract_characters(create :anime, name: 'Genshiken').size).to eq(9)
    end

    it 'Kuroshitsuji' do
      expect(parser.extract_characters(create :anime, name: 'Kuroshitsuji').size).to be >= 26
    end

    it "History's Strongest Disciple Kenichi" do
      expect(parser.extract_characters(create :anime, name: "History's Strongest Disciple Kenichi").size).to be >= 43
    end

    it 'Higashi no Eden' do
      expect(parser.extract_characters(create :anime, name: 'Higashi no Eden').size).to eq(17)
    end

    it 'Steins;Gate' do
      expect(parser.extract_characters(create :anime, name: 'Steins;Gate').size).to eq(9)
    end

    it 'Natsume Yuujinchou' do
      expect(parser.extract_characters(create :anime, name: 'Natsume Yuujinchou').size).to eq(7)
    end

    it 'Bleach' do
      expect(parser.extract_characters(bleach).size).to be >= 40
    end

    # it 'Noein: Mou Hitori no Kimi e' do
    #   parser.extract_characters(create :anime, name: 'Noein: Mou Hitori no Kimi e').should have_at_least(20).items
    # end

    it 'Code Geass' do
      expect(parser.extract_characters(create :anime, name: 'Code Geass').size).to be >= 40
    end

    it 'Chobits' do
      expect(parser.extract_characters(create :anime, name: 'Chobits').size).to be >= 17
    end

    it 'Chihayafuru' do
      expect(parser.extract_characters(create :anime, name: 'Chihayafuru').size).to be >= 7
    end

    it 'IS' do
      expect(parser.extract_characters(is).size).to eq(12)
    end

    it 'D.Gray-man' do
      expect(parser.extract_characters(create :anime, name: 'D.Gray-man').size).to be >= 32
    end

    it 'Fairy Tail' do
      expect(parser.extract_characters(create :anime, name: 'Fairy Tail').size).to be >= 30
    end

    it 'Naruto' do
      expect(parser.extract_characters(create :anime, name: 'Naruto').size).to be >= 70
    end

    it 'Pandora Hearts' do
      expect(parser.extract_characters(create :anime, name: 'Pandora Hearts').size).to be >= 21
    end

    it 'Maria†Holic' do
      expect(parser.extract_characters(create :anime, name: 'Maria†Holic').size).to eq(11)
    end

    it 'Lucky☆ Star' do
      expect(parser.extract_characters(create :anime, name: 'Lucky☆ Star', russian: 'Счастливая звезда').size).to be >= 4
    end

    it 'Trigun' do
      expect(parser.extract_characters(create :anime, name: 'Trigun').size).to eq(7)
    end

    it 'Sailor Moon' do
      expect(parser.extract_characters(create :anime, name: 'Sailor Moon', russian: 'Сейлор Мун').size).to eq(11)
    end

    it 'Air Gear' do
      expect(parser.extract_characters(create :anime, name: 'Air Gear').size).to be >= 23
    end

    it 'Read or Die' do
      expect(parser.extract_characters(create :anime, name: 'Read or Die', russian: 'Прочти или умри').size).to eq(24)
    end

    it 'Kingdom Hearts Birth by Sleep' do
      expect(parser.extract_characters(create :anime, name: 'Kingdom Hearts Birth by Sleep').size).to be >= 50
    end
  end
end
