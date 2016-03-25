describe AnimeSpiritParser, vcr: { cassette_name: 'anime_spirit_parser' } do
  let(:parser) { AnimeSpiritParser.new }

  it { expect(parser.fetch_pages_num).to eq 420 }
  it { expect(parser.fetch_page_links(1).size).to eq(10) }
  it { expect(parser.fetch_pages(1..1).size).to eq(10) }

  describe 'fetch_entry' do
    subject(:entry) { OpenStruct.new parser.fetch_entry link }
    context 'slayers' do
      let(:link) { 'http://www.animespirit.ru/anime/rs/series-rus/109-slayers-rubaki.html' }

      its(:russian) { is_expected.to eq 'Рубаки' }
      its(:name) { is_expected.to eq 'Slayers' }
      its(:names) { is_expected.to eq ['Рубаки', 'Slayers'] }
      its(:year) { is_expected.to eq 1995 }

      its(:videos) { is_expected.to have(26).items }
      its(:categories) { is_expected.to eq ['tv сериалы', 'фэнтези', 'комедия', 'приключения', 'мистика'] }
      its(:episodes) { is_expected.to eq 26 }
      its(:id) { is_expected.to eq link }

      context 'video' do
        subject { entry[:videos].first }
        its(:episode) { is_expected.to eq 1 }
        its(:source) { is_expected.to eq link }
        its(:url) { 'http://video.rutube.ru/cdc409fc58ac4ac357c98ae47d519208' }
        its(:kind) { is_expected.to eq :fandub }
        its(:author) { is_expected.to be nil }
      end
    end

    context 'Fix :author => "Филлер!" or "филлер" - https://github.com/morr/shikimori/issues/437' do
      let(:link) { 'http://www.animespirit.ru/anime/rs/series-rus/4320-naruto-uragannye-xroniki-naruto-shippuuden.html' }
      context 'video' do
        subject { entry[:videos].last }
        its(:author) { is_expected.to eq 'NIKITOS' }
      end
    end

    context 'binbougami' do
      let(:link) { 'http://www.animespirit.ru/anime/rs/series-rus/7837-nishhebog-zhe-binbougami-ga.html' }

      its(:russian) { is_expected.to eq 'Нищебог же!' }
      its(:name) { is_expected.to eq 'Binbougami ga!' }
      its(:year) { is_expected.to eq 2012 }

      its(:videos) { is_expected.to have(52).items }
      its(:episodes) { is_expected.to eq 13 }

      context 'video' do
        context 'first' do
          subject { entry[:videos].first }

          its(:episode) { is_expected.to eq 1 }
          its(:source) { is_expected.to eq link }
          its(:url) { is_expected.to eq '//myvi.tv/embed/html/oSTs693yvbob77Dom0Toa_b5OpvotLMAYhUh18hYP2b0euHBvbNKtSE2BVqVmcTiO0' }
          its(:kind) { is_expected.to eq :subtitles }
          its(:author) { is_expected.to be nil }
        end

        context 'last' do
          subject { entry[:videos].last }
          its(:author) { is_expected.to eq 'JAM & Kiara_Laine' }
          its(:episode) { is_expected.to eq 13 }
          its(:kind) { is_expected.to eq :fandub }
          its(:url) { is_expected.to eq '//video.sibnet.ru/shell.php?videoid=710879' }
        end
      end
    end

    context 'angel_beats' do
      let(:link) { 'http://www.animespirit.ru/anime/rs/series-rus/2406-angel-beats-mgnoveniya-angelov.html' }
      its(:russian) { is_expected.to eq 'Ангельские Ритмы!' }
      its(:name) { is_expected.to eq 'Angel Beats!' }
      its(:year) { is_expected.to eq 2010 }

      its(:videos) { is_expected.to have(130).items }
      its(:episodes) { is_expected.to eq 13 }
    end

    context 'buddy_complex' do
      let(:link) { 'http://www.animespirit.ru/anime/rs/series-rus/9639-druzheskij-kompleksbuddy-complex.html' }
      its(:episodes) { is_expected.to eq 13 }

      describe 'author in brackets' do
        subject { entry[:videos].select {|v| v.episode == 1 }.second }
        its(:kind) { is_expected.to eq :fandub }
        its(:author) { is_expected.to eq 'Cuba77 & Oriko' }
      end
    end

    context 'only one episode' do
      let(:link) { 'http://www.animespirit.ru/anime/141-burn-up-razgon.html' }

      its(:russian) { is_expected.to eq 'Разгон!' }
      its(:name) { is_expected.to eq 'Burn Up!' }
      its(:names) { is_expected.to eq ['Разгон!', 'Burn Up!'] }
      its(:year) { is_expected.to eq 1991 }

      its(:videos) { is_expected.to have(4).items }
      its(:episodes) { is_expected.to eq 1 }

      context 'video' do
        context 'first' do
          subject { entry[:videos].first }
          its(:author) { is_expected.to be nil }
          its(:episode) { is_expected.to eq 1 }
          its(:kind) { is_expected.to eq :subtitles }
        end

        context 'last' do
          subject { entry[:videos].last }
          its(:author) { is_expected.to eq 'Профессиональный (многоголосый, закадровый)' }
          its(:episode) { is_expected.to eq 1 }
          its(:kind) { is_expected.to eq :fandub }
        end
      end
    end

    context 'missing video' do
      let(:link) { 'http://www.animespirit.ru/anime/rs/series-rus/9715-korol-gyejner-overman-king-gainer.html' }
      its(:videos) { is_expected.to have(104).items }
    end

    #context 'translator in description' do
      #let(:link) { 'http://www.animespirit.ru/anime/rs/series-rus/882-gurren-lagann-tv-tengen-toppa-gurren-lagann.html' }
      #its(:videos) { is_expected.to have(54).items }

      #context :video do
        #subject { entry[:videos].last }

        #its(:kind) { is_expected.to eq :fandub }
        #its(:author) { is_expected.to eq 'Профессиональный (полное дублирование) [Reanimedia]' }
      #end
    #end

    context 'author without brackets' do
      let(:link) { 'http://www.animespirit.ru/anime/rs/series-rus/9459-master-kiton-tv-master-keaton.html' }

      context 'video' do
        subject { entry[:videos].last }
        its(:author) { 'Molodoy & KroshkaRu' }
        its(:kind) { is_expected.to eq :fandub }
      end
    end

    context 'kind with colon' do
      let(:link) { 'http://www.animespirit.ru/anime/rs/series-rus/9504-samurai-flamenco-samuraj-flamenko.html' }

      context 'video' do
        subject { entry[:videos].find {|v| v.author == 'Gezell Studio' } }
        its(:kind) { is_expected.to eq :fandub }
      end
    end

    context 'dorama ignore' do
      let(:link) { 'http://www.animespirit.ru/movies/dorama-rus/8325-velikij-uchitel-onidzuka-gto-great-teacher-onizuka.html' }
      its(:categories) { is_expected.to eq ['дорамы', 'комедия', 'школа'] }
    end

    #context 'live action ignore' do
      #let(:link) { 'http://www.animespirit.ru/movies/laction-rus/9644-chelovek-so-zvezdy-you-who-came-from-the-stars.html' }
      #its(:categories) { is_expected.to eq ['live action', 'фантастика', 'романтика'] }
    #end

    context 'special kind names' do
      let(:link) { 'http://www.animespirit.ru/anime/rs/ova-rus/1146-sladkie-kapelki-honey-x-honey-drops.html' }

      context 'video' do
        context 'first' do
          subject { entry[:videos].first }
          its(:episode) { is_expected.to eq 1 }
          its(:kind) { is_expected.to eq :subtitles }
          its(:author) { is_expected.to be nil }
        end

        context 'last' do
          subject { entry[:videos].last }
          its(:episode) { is_expected.to eq 2 }
          its(:kind) { is_expected.to eq :fandub }
          its(:author) { is_expected.to eq 'FaSt & Milirina' }
        end
      end
    end

    context 'subtitles special case' do
      let(:link) { 'http://www.animespirit.ru/anime/rs/series-rus/9192-klub-c179-vysshej-stupeni-zhenskoj-akademii.html' }

      context 'video' do
        context 'first' do
          subject { entry[:videos].first }
          its(:kind) { is_expected.to eq :subtitles }
        end
      end
    end

    context 'full date' do
      let(:link) { 'http://www.animespirit.ru/anime/rs/series-rus/9486-belyj-albom-2-white-album-2.html' }
      its(:year) { is_expected.to eq 2013 }
    end

    context 'name with /' do
      let(:link) { 'http://www.animespirit.ru/anime/rs/series-rus/9161-fatekaleid-liner-prisma-illyasudba-devochka.html' }
      its(:names) { is_expected.to eq ['Судьба / Девочка волшебница Илия', 'Fate/Kaleid Liner Prisma Illya'] }
    end
  end
end
