require 'spec_helper'

describe WikipediaParser do
  before (:each) { WikipediaParser.stub(:load_cache).and_return(animes: {}, characters: {}) }

  let (:parser) {
    p = WikipediaParser.new
    p.stub(:save_cache)
    p
  }

  let (:zero_no_tsukaima) { create :anime, name: 'Zero no Tsukaima', synonyms: ["Zero's Familiar"], english: ['The Familiar of Zero'] }
  let (:toradora) { create :anime, name: 'Toradora!' }
  let (:bleach) { create :anime, name: 'Bleach', russian: 'Блич' }
  let (:is) { create :anime, name: 'IS: Infinite Stratos' }

  it 'fetches pages from wikipedia' do
    data = parser.fetch_pages([zero_no_tsukaima.name.gsub(/ /, '_')])

    data.should have(1).item
    data[0][1].length.should > 15000
  end

  it 'fetches additional sources' do
    parser.fetch_anime(bleach).should have(2).items
  end

  it 'follows redirect while fetching page from wikipedia' do
    data = parser.fetch_pages([toradora.name])
    data.should have(1).item
    data[0][1].length.should > 15000
  end

  it 'replaces name with brackets' do
    parser.fetch_anime(is).should have(1).item
  end

  describe 'cleanup_wikitext' do
    it '—' do
      parser.cleanup_wikitext("—").should eq '-'
    end

    it '* Сейю: blablabla\\n' do
      parser.cleanup_wikitext("* Сейю: blablabla\n").should be_empty
    end

    it "''' Сейю '''" do
      parser.cleanup_wikitext("\n'''[[Сэйю]]:''' {{нл|Мэгуми|Тоёгути}}.\n").should eq "\n"
      parser.cleanup_wikitext("\n* '''[[Сэйю]]:''' {{нл|Мэгуми|Тоёгути}}.\n").should eq "\n"
    end

    it ': [[Сэйю]] — {{nl|Хирофумо|Нодзима}}.' do
      parser.cleanup_wikitext(": [[Сэйю]] — {{nl|Хирофумо|Нодзима}}.").should be_empty
    end

    it ': [[Сэйю]]: [[Косимидзу Ами]]\n' do
      parser.cleanup_wikitext(": [[Сэйю]]: [[Косимидзу Ами]]\n").should be_empty
    end

    it ': [[Сэйю]]: [[Косимидзу Ами]];' do
      parser.cleanup_wikitext(": [[Сэйю]]: [[Косимидзу Ами]];").should be_empty
    end

    it 'Сэйю — {{nl|Мисудзу|Тогаси}}.' do
      parser.cleanup_wikitext("Сэйю — {{nl|Мисудзу|Тогаси}}.").should be_empty
    end

    it '* [[Файл:Chara 02.jpg|thumb|Сиэль Фантомхайв]]' do
      parser.cleanup_wikitext('* [[Файл:Chara 02.jpg|thumb|Сиэль Фантомхайв]]').should eq '* '
    end

    it '[[файл:Chara 02.jpg|thumb|[[Сиэль Фантомхайв]]]]' do
      parser.cleanup_wikitext('[[файл:Chara 02.jpg|thumb|[[Сиэль Фантомхайв]]]]').should be_empty
    end

    it 'source' do
      parser.cleanup_wikitext("{{Источник:Блич|1|7|173}}").should be_empty
      parser.cleanup_wikitext("{{Source:Блич|1|7|173}}").should be_empty
    end

    it 'comments' do
      parser.cleanup_wikitext("&lt;!-- Имя написано согласно правилам чтения японских слов!-->\n").should be_empty
      parser.cleanup_wikitext("&lt;!-- Имя написано согласно правилам чтения японских слов-->\n").should be_empty
    end

    it 'single refs' do
      parser.cleanup_wikitext("<ref xzxcvxcv/>test<ref zxczxc>zxc</ref>aa").should eq 'testaa'
    end

    it '[[wiktionary:茶|茶]]' do
      parser.cleanup_wikitext('[[wiktionary:茶|茶]]').should eq '茶'
    end

    it "{{нп3|Каго,_Ай|Ай Каго||Ai Kago}}" do
      parser.cleanup_wikitext("{{нп3|Каго,_Ай|Ай Каго||Ai Kago}}").should eq 'Ai Kago'
    end

    it 'refs' do
      parser.cleanup_wikitext("<ref xzxcvxcv>test</ref>tqqqw&lt;ref fdsdf>&lt;/ref>").should eq 'tqqqw'
    end

    it 'nl' do
      parser.cleanup_wikitext("{{nl|zxc|cvb}}").should eq 'cvb'
      parser.cleanup_wikitext("{{nl|cvb}}").should eq 'cvb'
    end

    it 'что?' do
      parser.cleanup_wikitext("{{что?}}").should be_empty
    end

    it '{{disambig}}' do
      parser.cleanup_wikitext("{{disambig}}").should be_empty
    end

    it '<center>' do
      parser.cleanup_wikitext("&lt;center>test&lt;/center>").should eq '<center>test</center>'
    end

    it '<br>' do
      parser.cleanup_wikitext("<br>").should eq "\n"
      parser.cleanup_wikitext("<br >").should eq "\n"
      parser.cleanup_wikitext("<br/>").should eq "\n"
      parser.cleanup_wikitext("<br />").should eq "\n"
      parser.cleanup_wikitext("&lt;br />").should eq "\n"
    end

    it '<br clear="left">' do
      parser.cleanup_wikitext("<br clear=\"left\">").should eq "\n"
      parser.cleanup_wikitext("<br clear=\"left\" >").should eq "\n"
      parser.cleanup_wikitext("<br clear=left>").should eq "\n"
      parser.cleanup_wikitext("<br clear=\"left\" \>").should eq "\n"
      parser.cleanup_wikitext("&lt;br clear=\"left\">").should eq "\n"
    end

    #it '{{Китайский||李盖梅||Ли Гаймэй}}' do
      #parser.cleanup_wikitext("{{Китайский||李盖梅||Ли Гаймэй}}").should eq 'Ли Гаймэl (李盖梅)'
    #end

    it '{{не переведено|есть=:en:ofuda|надо=офуда|текст=|язык=en|nocat=1}}' do
      parser.cleanup_wikitext('{{не переведено|есть=:en:ofuda|надо=офуда|текст=|язык=en|nocat=1}}').should eq 'офуда'
    end

    it '{{who}}' do
      parser.cleanup_wikitext('{{who}}').should be_empty
    end

    it '{{who?}}' do
      parser.cleanup_wikitext('{{who?}}').should be_empty
    end

    it '{{кто}}' do
      parser.cleanup_wikitext('{{кто}}').should be_empty
    end

    it '{{кто?}}' do
      parser.cleanup_wikitext('{{кто?}}').should be_empty
    end

    it '{{Abbr|SSTV|Station Square Television|0}}' do
      parser.cleanup_wikitext('{{Abbr|SSTV|Station Square Television|0}}').should eq 'SSTV'
    end

    it '{{Abbr|SSTV}}' do
      parser.cleanup_wikitext('{{Abbr|SSTV}}').should eq 'SSTV'
    end

    it '{{чего}}' do
      parser.cleanup_wikitext('{{чего}}').should be_empty
    end

    it '{{что}}' do
      parser.cleanup_wikitext('{{что}}').should be_empty
    end

    it '{{cite web |.*}}' do
      parser.cleanup_wikitext('{{cite web |url = http://www.animenewsnetwork.com/review/death-note/dvd-7 |title = Death Note DVD 7 |author = Theron Martin |date = 2009.02.09 |work = [[AnimeNewsNetwork]] |publisher =  |accessdate = 2012-04-22 |lang = en}}').should be_empty
    end

    it '{{Переход|#Марс в античной мифологии|green}}' do
      parser.cleanup_wikitext('{{Переход|#Марс в античной мифологии|green}}').should be_empty
    end

    it '{{цитата|Ха! Я придумал слово невозможно. Вот почему я чемпион. Нравится ли мне это или нет}}' do
      parser.cleanup_wikitext('{{цитата|Ха! Я придумал слово невозможно. Вот почему я чемпион. Нравится ли мне это или нет}}').should eq "[quote]Ха! Я придумал слово невозможно. Вот почему я чемпион. Нравится ли мне это или нет[/quote]"
    end

    it '{{vgy|zxc|cvb}}' do
      parser.cleanup_wikitext('{{vgy|zxc|cvb}}').should eq 'cvb'
      parser.cleanup_wikitext('{{vgy|cvb}}').should eq 'cvb'
    end

    it '{{nobr|test test}}' do
      parser.cleanup_wikitext('{{nobr|test test}}').should eq 'test test'
    end

    it '{{хангыль|Им Ёнсу|임용수|Im Yong Soo|также {{イ・ヨンス}}}}' do
      parser.cleanup_wikitext("{{хангыль|Им Ёнсу|임용수|Im Yong Soo|также {{イ・ヨンス}}}}").should eq 'Им Ёнсу'
    end

    it '{{anime voice}}' do
      parser.cleanup_wikitext("\n: {{anime voice}} tstebc").should be_empty
      parser.cleanup_wikitext('{{anime voice}}').should be_empty
    end

    it '{{anchor|test}}' do
      parser.cleanup_wikitext('{{anchor|test}}').should be_empty
      parser.cleanup_wikitext('{{якорь|test}}').should be_empty
    end

    it '{{уточнить}}' do
      parser.cleanup_wikitext('{{уточнить}}').should be_empty
    end

    it '{{Китайский|[臧]春麗|[臧]春丽|Chūnlì}}' do
      parser.cleanup_wikitext("{{Китайский|[臧]春麗|[臧]春丽|Chūnlì}}").should eq '[臧]春麗'
    end

    it '{{ref|J210|гл.210}}' do
      parser.cleanup_wikitext("{{ref|J210|гл.210}}").should be_empty
    end

    it '{{нет АИ|15|09|2011}}' do
      parser.cleanup_wikitext("{{нет АИ|15|09|2011}}").should be_empty
      parser.cleanup_wikitext("{{Нет АИ|15|09|2011}}").should be_empty
    end

    it '{{Кратко о персонаже}}' do
      parser.cleanup_wikitext("{{Кратко о персонаже|\n| ааа   = 123\n| ббб=456\n}}").should eq "** Ааа: 123\n** Ббб: 456\n"
    end

    it '{{Персонаж аниме/манги}}' do
      parser.cleanup_wikitext("{{Персонаж аниме/манги\n| ааа   = 123\n| ббб=456\n}}").should eq "** Ааа: 123\n** Ббб: 456\n"
    end

    it 'two {{Персонаж аниме/манги}}' do
      parser.cleanup_wikitext("{{Персонаж аниме/манги\n| ааа   = 123\n| ббб=456\n}}\nzxc\n{{Персонаж аниме/манги\n| ааа   = 123\n| ббб=456\n}}").should eq "** Ааа: 123\n** Ббб: 456\n\nzxc\n** Ааа: 123\n** Ббб: 456\n"
    end

    it '{{ options }} {{Персонаж аниме/манги}}' do
      parser.cleanup_wikitext("{{Персонаж аниме/манги\n| ааа   = {{123}}\n| {{ббб}}=456\n}}").should eq "** Ааа: {{123}}\n** {{ббб}}: 456\n"
    end

    it 'empty options in {{Персонаж аниме/манги}}' do
      parser.cleanup_wikitext("{{Персонаж аниме/манги\n| ааа   = 123\n| ббб=456\n| ссс   = \n}}").should eq "** Ааа: 123\n** Ббб: 456\n"
    end

    it 'forbidden options in {{Персонаж аниме/манги}}' do
      parser.cleanup_wikitext("{{Персонаж аниме/манги\n | ааа   = 123\n| ббб=456\n| цвет   = 123\n| имя=456\n}}").should eq "** Ааа: 123\n** Ббб: 456\n"
    end

    it 'long {{Персонаж аниме/манги}}' do
      parser.cleanup_wikitext("==== Дзирайя ====
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
медицинских целях или в комбинированной атаке с жабами.").should include(
          "==== Дзирайя ====\n** Появление: Манга: 90 глава, Аниме: I часть 52 серия\n** Возраст: I ч. - 50-51 лет, II ч. - 54 лет (убит)\n")
    end

    it '{{Смотри также...}}' do
      parser.cleanup_wikitext("{{Смотри также|Список серий Naruto:  1-4)|Списо 5-8)|Список сери 9-12)}}").should be_empty
    end

    it '<gallery>' do
      parser.cleanup_wikitext("<gallery perrow=\"5\" width=\"90%\">
<!-- Порядок дан по алфавиту-->
Файл:Kazekage hat (Naruto, manga).svg|Головной убор <!--Не изменяйте, всё правильно! См. страницу обсуждения этой статьи!-->Кадзэкагэ
Файл:Mizukage hat (Naruto, manga).svg|Головной убор <!--Не изменяйте, всё правильно! См. страницу обсуждения этой статьи!-->Мидзукагэ
Файл:Raikage hat (Naruto, manga).svg|Головной убор Райкагэ
Файл:Chapeau Hiruzen Sarutobi.svg|Головной убор Хокагэ
Файл:Tsuchikage hat (Naruto, manga).svg|Головной убор Цутикагэ
</gallery>").should be_empty
    end

    it 'quotes' do
      parser.cleanup_wikitext("{{начало цитаты}}zxc\n{{конец цитаты|источник=«Noein»}}").should be_empty
    end
  end

  describe 'cleanup_description' do
    it '^:' do
      parser.cleanup_description(': ', russian: '').should be_empty
    end

    it '^*' do
      parser.cleanup_description('* ', russian: '').should be_empty
    end

    it '- bla' do
      parser.cleanup_description('- bla', russian: '').should eq 'Bla'
      parser.cleanup_description(', bla', russian: '').should eq 'Bla'
    end

    it 'nihongo' do
      parser.cleanup_description("{{nihongo|'''Иссин Куросаки'''|黒崎 一心|Куросаки Иссин|''Kurosaki Isshin''}}", russian: '').should eq 'Иссин Куросаки'
    end

    it 'nihongo with notice' do
      parser.cleanup_description("{{Нихонго|Мессер|メッサー|мэсса:|{{lang-de|Messer}} — «нож»}}", russian: '').should eq 'Мессер'
    end

    it "'''" do
      parser.cleanup_description("'''Иссин Куросаки'''", russian: '').should eq 'Иссин Куросаки'
    end

    it "''" do
      parser.cleanup_description("''Иссин Куросаки''", russian: '').should eq 'Иссин Куросаки'
    end

    it "{{lang" do
      parser.cleanup_description("{{lang-ja2|Engetsu}}", russian: '').should eq 'Engetsu'
    end

    it "name in the beginning" do
      parser.cleanup_description("Иссин Куросаки - test", russian: 'Иссин Куросаки').should eq 'Test'
      parser.cleanup_description("Иссин Куросаки — test", russian: 'Иссин Куросаки').should eq 'Test'
      parser.cleanup_description("Иссин Куросаки, test", russian: 'Иссин Куросаки').should eq 'Test'
      parser.cleanup_description("{{нихонго|''XXX''|test}} <br />\n test", russian: 'XXX').should eq 'Test'
      parser.cleanup_description("Иссин Куросаки <br />\n test", russian: 'Иссин Куросаки').should eq 'Test'
      parser.cleanup_description("Иссин Куросаки \n test", russian: 'Иссин Куросаки').should eq 'Test'
    end

    it 'first symbol uppercased' do
      parser.cleanup_description("иссин", russian: '').should eq 'Иссин'
    end

    it 'list in the beginning' do
      parser.cleanup_description("\n: ZXC\n: CCC", russian: '').should eq "[list]\n[*] ZXC\n[*] CCC\n[/list]"
    end

    it 'process list in any part' do
      parser.cleanup_description("test\n: ZXC\n: CCC", russian: '').should eq "Test\n[list]\n[*] ZXC\n[*] CCC\n[/list]"
    end

    it 'Seyu in the beginnig' do
      parser.cleanup_description("* Сэйю — {{nl|Дзюн|Фукуяма}} (Период детства озвучивает {{nl|Саяка|Охара}})\nTest", russian: '').should eq "Test"
      parser.cleanup_description("[*] Сэйю — {{nl|Дзюн|Фукуяма}} (Период детства озвучивает {{nl|Саяка|Охара}})\nTest", russian: '').should eq "Test"
    end

    it '{{main}}' do
      parser.cleanup_description("{{main|test}}", russian: '').should be_empty
    end

    it '<center>' do
      parser.cleanup_description("<center>test</center>", russian: '').should eq "[b]test[/b]"
    end
  end

  describe 'characters extraction' do
    describe 'default' do
      it '{{Опсание персонажа}}' do
        parser.extract_default("
{{Описание персонажа
  | имя      = Аква
  | кандзи   = アクア
  | киридзи  = Акуа
  | описание = DESCRIPTION
  | сэйю     = {{nl|Мэгуми|Тоёгути}}
}}").should eq [{russian: 'Аква', japanese: 'アクア', description: 'DESCRIPTION'}]
      end

      it 'extracts full name' do
        parser.extract_default("
{{Описание персонажа
 | имя      = Луиза (полное имя Кирхе [[Екатерина II|Луиза Фредерика фон Анхальт-Цербст]])
 | описание = DESCRIPTION
 | сэйю     = {{nl|Нанако|Иноуэ}}
}}").should eq [{russian: 'Луиза Фредерика фон Анхальт-Цербст', japanese: nil, description: 'DESCRIPTION'}]
      end
    end

    describe 'old default' do
      it 'detailed data' do
        parser.extract_default_old("«Блич»|проводников душ]]», воинов, которые защищают людей, сражаясь со злыми духами [[Пустые (Bleach)|пустыми]], и помогают добрым душам уйти в [[Загробный мир|мир иной]].
  : [[Сэйю]] — {{nl|Масакадзу|Морита}}.

  === Рукия Кучики ===
  {{main|Рукия Кучики}}
  Рукия Кучики — девушка-проводник душ, которая была отправлена патрулировать родной город Ичиго и защищать жителей от пустых, а также отправлять души умерших в [[Блич#Мир|Сообщество душ]] ([[загробный мир]]), совершая обряд {{nihongo|погребения души|魂葬|консо:}}. Несмотря на то что она выглядит, как [[подросток]], ей в действительности более 150-ти лет. По ряду обстоятельств Рукия вынуждена передать свою духовную энергию Ичиго и вести жизнь обычного человека, находясь в гигае («временном теле»), которое проводники душ используют в экстренных ситуациях.{{Источник:Блич|1|2|71}} После утраты сил она способна лишь на мелкие заклинания.{{Источник:Блич|1|2|70}} Рукии нравится жить в мире людей, она обладает странноватым чувством юмора и сварливым характером, любит объяснять всё в виде собственноручно нарисованных [[комикс]]ов. Рукия является первым персонажем, придуманным автором.<ref name=\"About 1\">{{cite web|url= http://manga.about.com/od/mangaartistinterviews/a/TiteKubo.htm |title= Interview: Tite Kubo (стр. 1)|author=Дэб Аоки. |publisher=[[About.com]] |lang = en| accessdate= 2008-09-25}}</ref>
  : [[Сэйю]] — {{nl|Фумико|Орикаса}}.

  === Орихимэ Иноуэ ===", WikipediaParser::CharacterDetailedRegexp).should eq [{
            russian: 'Рукия Кучики',
            description: "Девушка-проводник душ, которая была отправлена патрулировать родной город Ичиго и защищать жителей от пустых, а также отправлять души умерших в [[Блич#Мир|Сообщество душ]] ([[загробный мир]]), совершая обряд погребения души. Несмотря на то что она выглядит, как [[подросток]], ей в действительности более 150-ти лет. По ряду обстоятельств Рукия вынуждена передать свою духовную энергию Ичиго и вести жизнь обычного человека, находясь в гигае («временном теле»), которое проводники душ используют в экстренных ситуациях. После утраты сил она способна лишь на мелкие заклинания. Рукии нравится жить в мире людей, она обладает странноватым чувством юмора и сварливым характером, любит объяснять всё в виде собственноручно нарисованных [[комикс]]ов. Рукия является первым персонажем, придуманным автором."
          }
        ]
      end

      it 'common data' do
        parser.extract_default_old("\n* {{Нихонго-но-намаэ|'''Карин Куросаки'''|黒崎 夏梨}} — дочь Иссина, сестра-[[близнец]] Юдзу, младше Ичиго на четыре года.",
                              WikipediaParser::CharacterDetailedRegexp).should eq [{
            russian: 'Карин Куросаки',
            japanese: '黒崎 夏梨',
            description: "Дочь Иссина, сестра-[[близнец]] Юдзу, младше Ичиго на четыре года."
          }
        ]
      end

      it 'common data with \[\[ \]\]' do
        parser.extract_default_old("\n* {{Нихонго-но-намаэ|\[\[Карин Куросаки#Карин Куросаки|Test\]\]|黒崎 夏梨}} — Zzz.",
                              WikipediaParser::CharacterDetailedRegexp).should eq [{
            russian: 'Test',
            japanese: '黒崎 夏梨',
            description: "Zzz."
          }
        ]
      end

      it 'common data with english name tag' do
        parser.extract_default_old("\n: {{Нихонго-но-намаэ|'''Карин Куросаки'''|黒崎 夏梨|Куросаки Карин|''Kurosaki Karin''}} — дочь Иссина, сестра-[[близнец]] Юдзу, младше Ичиго на четыре года.",
                              WikipediaParser::CharacterDetailedRegexp).should eq [{
            russian: 'Карин Куросаки',
            japanese: '黒崎 夏梨',
            english: 'Kurosaki Karin',
            description: "Дочь Иссина, сестра-[[близнец]] Юдзу, младше Ичиго на четыре года."
          }
        ]
      end

      it 'common data with additional {{ tag }}' do
        parser.extract_default_old("\n{{Нихонго-но-намаэ|'''Карин Куросаки'''|黒崎 夏梨|{{lang-en|Love}} — «любовь»}} — дочь Иссина, сестра-[[близнец]] Юдзу, младше Ичиго на четыре года.",
                              WikipediaParser::CharacterDetailedRegexp).should eq [{
            russian: 'Карин Куросаки',
            japanese: '黒崎 夏梨',
            english: 'Love',
            description: "Дочь Иссина, сестра-[[близнец]] Юдзу, младше Ичиго на четыре года."
          }
        ]
      end

      it "'''name'''" do
        parser.extract_default_old("\n'''Луиза''' ({{lang-en|Louise}}, {{lang-ja|ルイズ}} ''Руидзу'')\n\nЛуиза — главная героиня",
                              WikipediaParser::CharacterDetailedRegexp).should eq [{
            russian: 'Луиза',
            japanese: 'ルイズ',
            english: 'Louise',
            description: "Главная героиня"
          }
        ]
      end

      it "data with name in square brackets" do
        parser.extract_default_old("\n{{нихонго|[[Лелуш Ламперуж]]|ルルーシュ・ランペルージ|Руру:сю Рампэру:дзи}}\nTest",
                              WikipediaParser::CharacterDetailedRegexp).should eq [{
            russian: 'Лелуш Ламперуж',
            japanese: 'ルルーシュ・ランペルージ',
            description: "Test"
          }
        ]
      end

      it "list after name block" do
        parser.extract_default_old("\n{{нихонго|[[Лелуш Ламперуж]]|ルルーシュ・ランペルージ|Руру:сю Рампэру:дзи}}\n: '''Возраст:''' I арка — 17 лет, II арка — 18 лет\n: '''Национальность''' — британец\nTest",
                              WikipediaParser::CharacterDetailedRegexp).should eq [{
            russian: 'Лелуш Ламперуж',
            japanese: 'ルルーシュ・ランペルージ',
            description: "[list]\n[*] Возраст: I арка - 17 лет, II арка - 18 лет\n[*] Национальность - британец\n[/list]\nTest"
          }
        ]
      end

      it "japanese name" do
        parser.extract_default_old("\n{{нихонго|Чарльз ди Британия|シャルル・ジ・ブリタニア|Сяруру дзи Буританиа}}\nTest",
                              WikipediaParser::CharacterDetailedRegexp).should eq [{
            russian: 'Чарльз ди Британия',
            japanese: 'シャルル・ジ・ブリタニア',
            description: 'Test'
          }
        ]
      end

      it "simple japanese name" do
        parser.extract_default_old("\n{{нихонго|Нагато|永田}}\nTest",
                              WikipediaParser::CharacterDetailedRegexp).should eq [{
            russian: 'Нагато',
            japanese: '永田',
            description: 'Test'
          }
        ]
      end

      it "colon in the beginning and seyu before" do
        parser.extract_default_old("\n{{нихонго|Нагато|永田}}\n:Сэйю: [[Каори Надзука]]\n: Лучшая подружка Араси.",
                              WikipediaParser::CharacterDetailedRegexp).should eq [{
            russian: 'Нагато',
            japanese: '永田',
            description: 'Лучшая подружка Араси.'
          }
        ]
      end

      it "with seyu" do
        parser.extract_default_old("\n{{нихонго-но-намаэ|'''Симазаки'''|島崎|Симазаки|[[Сэйю]] — [[Риэ Танака]]}}\nTest",
                              WikipediaParser::CharacterDetailedRegexp).should eq [{
            russian: 'Симазаки',
            japanese: '島崎',
            description: 'Test'
          }
        ]
      end
    end

    describe 'by_header' do
      it 'common name' do
        parser.extract_by_header("=== Ю Канда ===\n {{нихонго|'''Ю Канда'''|神田 ユウ|Канда Ю:}} — парень 18 лет, который имеет очень сложный характер.").should eq [{
            russian: 'Ю Канда',
            japanese: '神田 ユウ',
            description: 'Парень 18 лет, который имеет очень сложный характер.'
          }
        ]
      end

      it "'''name'''" do
        parser.extract_by_header("=== '''Ю Канда''' ===\n {{нихонго|'''Ю Канда'''|神田 ユウ|Канда Ю:}} — парень 18 лет, который имеет очень сложный характер.").should eq [{
            russian: 'Ю Канда',
            japanese: '神田 ユウ',
            description: 'Парень 18 лет, который имеет очень сложный характер.'
          }
        ]
      end

      it '[[name]]' do
        parser.extract_by_header("=== [[Ю Канда]] ===\n {{нихонго|'''Ю Канда'''|神田 ユウ|Канда Ю:}} — парень 18 лет, который имеет очень сложный характер.").should eq [{
            russian: 'Ю Канда',
            japanese: '神田 ユウ',
            description: 'Парень 18 лет, который имеет очень сложный характер.'
          }
        ]
      end

      it 'separate line' do
        parser.extract_by_header("=== Алма Карма ===
{{нихонго|''Алма Карма''|アルマ カルマ|Арума Карума}}
Алма Карма был единственным Вторым Экзорцистом, успешно созданным по Программе Искусственных Апостолов, за исключением Ю Канды.").should eq [{
            russian: 'Алма Карма',
            japanese: 'アルマ カルマ',
            description: "Алма Карма был единственным Вторым Экзорцистом, успешно созданным по Программе Искусственных Апостолов, за исключением Ю Канды."
          }
        ]
      end

      it 'extended header' do
        parser.extract_by_header("=== Бак Чан ===
{{нихонго|''Бак Чан''|バク・チャン|Баку Тян}}, ({{Китайский||白灿||Бай Цань}}, в тайваньском переводе {{Китайский||莫·张||Мо ЧЖАН}} или {{Китайский||巴克·强||Бакэ ЦЯН}})
ZXC").should eq [{
            russian: 'Бак Чан',
            japanese: 'バク・チャン',
            description: 'ZXC'
          }
        ]
      end

      it 'extended header on one line' do
        parser.extract_by_header("=== Комуи Ли ===
{{нихонго|''Комуи Ли''|コムイ・リー|Комуи Ри:}} ({{Китайский||李盖梅||Ли Гаймэй}}，''в тайваньском переводе'' 科穆伊·李 или 考姆伊) — старший брат Линали Ли.").should eq [{
            russian: 'Комуи Ли',
            japanese: 'コムイ・リー',
            description: 'Комуи Ли - старший брат Линали Ли.'
          }
        ]
      end

      it 'with list in the beginning' do
        parser.extract_by_header("==== Бодзо ====\n: Возраст: неизвестен\n: Род занятий: маг\n{{nihongo|Бодзо|ボゾ}} — присутствует только в аниме.").should eq [{
            russian: 'Бодзо',
            japanese: 'ボゾ',
            description: "[list]\n[*] Возраст: неизвестен\n[*] Род занятий: маг\n[/list]\nПрисутствует только в аниме."
          }
        ]
      end
    end
  end

  describe 'extract characters' do
    it 'Zero no Tsukaima' do
      chars = parser.extract_characters(zero_no_tsukaima)

      chars.should have(13).items

      chars.first[:russian].should eq 'Луиза Франсуаза ле Блан де ла Вальер де Тристейн'
      chars.first[:english].should be_nil
      chars.first[:japanese].should be_nil

      chars.last[:russian].should eq 'Лонгвиль'
      chars.last[:english].should be_nil
      chars.last[:japanese].should be_nil
    end

    it 'Toradora!' do
      parser.extract_characters(toradora).should have_at_least(5).items
    end

    it 'Spice and Wolf' do
      chars = parser.extract_characters(create :anime, name: 'Spice and Wolf')

      chars.should have_at_least(4).items
      chars[1][:russian].should eq 'Крафт Лоурэнс'
    end

    it 'Shiki' do
      parser.extract_characters(create :anime, name: 'Shiki').should have(8).items
    end

    it 'Myself ; Yourself' do
      parser.extract_characters(create :anime, name: 'Myself ; Yourself').should have(8).items
    end

    it 'Mirai Nikki' do
      chars = parser.extract_characters(create :anime, name: 'Mirai Nikki')

      chars.select{|v| v[:russian].include? 'Deus'}.first[:japanese].should eq 'デウス・エクス・マキナ'

      chars.should have(18).items
      chars.first[:russian].should eq 'Юкитэру Амано'
      chars.first[:japanese].should eq '天野雪輝'
    end

    it 'Freezing' do
      parser.extract_characters(create :anime, name: 'Freezing').should have(25).items
    end

    it 'Aria' do
      parser.extract_characters(create :anime, name: 'Aria').should have_at_least(13).items
    end

    it 'Death Note' do
      parser.extract_characters(create :anime, name: 'Death Note').should have_at_least(50).items
    end

    it 'Ah! My Goddess' do
      parser.extract_characters(create :anime, name: 'Ah! My Goddess').should have_at_least(33).items
    end

    it 'Seitokai no Ichizon' do
      parser.extract_characters(create :anime, name: 'Seitokai no Ichizon').should have(5).items
    end

    it 'Genshiken' do
      parser.extract_characters(create :anime, name: 'Genshiken').should have(9).items
    end

    it 'Kuroshitsuji' do
      parser.extract_characters(create :anime, name: 'Kuroshitsuji').should have_at_least(26).items
    end

    it "History's Strongest Disciple Kenichi" do
      parser.extract_characters(create :anime, name: "History's Strongest Disciple Kenichi").should have_at_least(43).items
    end

    it 'Higashi no Eden' do
      parser.extract_characters(create :anime, name: 'Higashi no Eden').should have(4).items
    end

    it 'Steins;Gate' do
      parser.extract_characters(create :anime, name: 'Steins;Gate').should have(10).items
    end

    it 'Natsume Yuujinchou' do
      parser.extract_characters(create :anime, name: 'Natsume Yuujinchou').should have(7).items
    end

    it 'Bleach' do
      parser.extract_characters(bleach).should have_at_least(40).items
    end

    #it 'Noein: Mou Hitori no Kimi e' do
      #parser.extract_characters(create :anime, name: 'Noein: Mou Hitori no Kimi e').should have_at_least(20).items
    #end

    it 'Code Geass' do
      parser.extract_characters(create :anime, name: 'Code Geass').should have_at_least(40).items
    end

    it 'Chobits' do
      parser.extract_characters(create :anime, name: 'Chobits').should have_at_least(17).items
    end

    it 'Chihayafuru' do
      parser.extract_characters(create :anime, name: 'Chihayafuru').should have_at_least(7).items
    end

    it 'IS' do
      parser.extract_characters(is).should have(12).items
    end

    it 'D.Gray-man' do
      parser.extract_characters(create :anime, name: 'D.Gray-man').should have_at_least(32).items
    end

    it 'Fairy Tail' do
      parser.extract_characters(create :anime, name: 'Fairy Tail').should have_at_least(30).items
    end

    it 'Naruto' do
      parser.extract_characters(create :anime, name: 'Naruto').should have_at_least(70).items
    end

    it 'Pandora Hearts' do
      parser.extract_characters(create :anime, name: 'Pandora Hearts').should have_at_least(21).items
    end

    it 'Maria†Holic' do
      parser.extract_characters(create :anime, name: 'Maria†Holic').should have(11).items
    end

    it 'Lucky☆ Star' do
      parser.extract_characters(create :anime, name: 'Lucky☆ Star', russian: 'Счастливая звезда').should have_at_least(4).items
    end

    it 'Trigun' do
      parser.extract_characters(create :anime, name: 'Trigun').should have(7).items
    end

    it 'Sailor Moon' do
      parser.extract_characters(create :anime, name: 'Sailor Moon', russian: 'Сейлор Мун').should have(11).items
    end

    it 'Air Gear' do
      parser.extract_characters(create :anime, name: 'Air Gear').should have_at_least(23).items
    end

    it 'Read or Die' do
      parser.extract_characters(create :anime, name: 'Read or Die', russian: 'Прочти или умри').should have(24).items
    end

    it 'Kingdom Hearts Birth by Sleep' do
      parser.extract_characters(create :anime, name: 'Kingdom Hearts Birth by Sleep').should have_at_least(50).items
    end
  end
end
