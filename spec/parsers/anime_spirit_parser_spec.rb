require 'spec_helper'

describe AnimeSpiritParser do
  let(:parser) { AnimeSpiritParser.new }

  it { parser.fetch_pages_num.should eq 389 }
  it { parser.fetch_page_links(1).should have(10).items }
  it { parser.fetch_pages(1..1).should have(10).items }

  describe :fetch_entry do
    subject(:entry) { OpenStruct.new parser.fetch_entry link }
    context :slayers do
      let(:link) { 'http://www.animespirit.ru/anime/rs/series-rus/109-slayers-rubaki.html' }

      its(:russian) { should eq 'Рубаки' }
      its(:name) { should eq 'Slayers' }
      its(:names) { should eq ['Рубаки', 'Slayers'] }
      its(:year) { should eq 1995 }
      its(:videos) { should have(26).items }
      its(:categories) { should eq ['TV сериалы'] }
      its(:episodes) { should eq 26 }
      its(:id) { should eq link }

      context :video do
        subject { entry[:videos].first }
        its(:episode) { should eq 1 }
        its(:source) { should eq link }
        its(:url) { 'http://video.rutube.ru/cdc409fc58ac4ac357c98ae47d519208' }
        its(:kind) { should eq :fandub }
        its(:author) { should be nil }
      end
    end

    context :binbougami do
      let(:link) { 'http://www.animespirit.ru/anime/rs/series-rus/7837-nishhebog-zhe-binbougami-ga.html' }

      its(:russian) { should eq 'Нищебог же!' }
      its(:name) { should eq 'Binbougami ga!' }
      its(:year) { should eq 2012 }
      its(:videos) { should have(52).items }
      its(:episodes) { should eq 13 }

      context :video do
        context :first do
          subject { entry[:videos].first }

          its(:episode) { should eq 1 }
          its(:source) { should eq link }
          its(:url) { should eq 'http://myvi.ru/ru/flash/player/pre/oSTs693yvbob77Dom0Toa_b5OpvotLMAYhUh18hYP2b0euHBvbNKtSE2BVqVmcTiO0' }
          its(:kind) { should eq :subtitles }
          its(:author) { should be nil }
        end

        context :last do
          subject { entry[:videos].last }
          its(:author) { should eq 'JAM & Kiara_Laine' }
          its(:episode) { should eq 13 }
          its(:kind) { should eq :fandub }
          its(:url) { should eq 'http://video.sibnet.ru/shell.swf?videoid=710879' }
        end
      end
    end

    context :angel_beats do
      let(:link) { 'http://www.animespirit.ru/anime/rs/series-rus/2406-angel-beats-mgnoveniya-angelov.html' }
      its(:russian) { should eq 'Ангельские Ритмы!' }
      its(:name) { should eq 'Angel Beats!' }
      its(:year) { should eq 2010 }
      its(:videos) { should have(130).items }
      its(:episodes) { should eq 13 }
    end

    context :buddy_complex do
      let(:link) { 'http://www.animespirit.ru/anime/rs/series-rus/9639-druzheskij-kompleksbuddy-complex.html' }
      its(:episodes) { should eq 12 }

      describe 'author in brackets' do
        subject { entry[:videos].select {|v| v.episode == 1 }.second }
        its(:kind) { should eq :fandub }
        its(:author) { should eq 'Cuba77 & Oriko' }
      end
    end

    context 'only one episode' do
      let(:link) { 'http://www.animespirit.ru/anime/141-burn-up-razgon.html' }

      its(:russian) { should eq 'Разгон!' }
      its(:name) { should eq 'Burn Up!' }
      its(:names) { should eq ['Разгон!', 'Burn Up!'] }
      its(:year) { should eq 1991 }
      its(:videos) { should have(4).items }
      its(:episodes) { should eq 1 }

      context :video do
        context :first do
          subject { entry[:videos].first }
          its(:author) { should be nil }
          its(:episode) { should eq 1 }
          its(:kind) { should eq :subtitles }
        end

        context :last do
          subject { entry[:videos].last }
          its(:author) { should eq 'Профессиональный (многоголосый, закадровый)' }
          its(:episode) { should eq 1 }
          its(:kind) { should eq :fandub }
        end
      end
    end

    context 'missing video' do
      let(:link) { 'http://www.animespirit.ru/anime/rs/series-rus/9715-korol-gyejner-overman-king-gainer.html' }
      its(:videos) { should have(67).items }
    end

    #context 'translator in description' do
      #let(:link) { 'http://www.animespirit.ru/anime/rs/series-rus/882-gurren-lagann-tv-tengen-toppa-gurren-lagann.html' }
      #its(:videos) { should have(54).items }

      #context :video do
        #subject { entry[:videos].last }

        #its(:kind) { should eq :fandub }
        #its(:author) { should eq 'Профессиональный (полное дублирование) [Reanimedia]' }
      #end
    #end

    context 'author without brackets' do
      let(:link) { 'http://www.animespirit.ru/anime/rs/series-rus/9459-master-kiton-tv-master-keaton.html' }

      context :video do
        subject { entry[:videos].last }
        its(:author) { 'Molodoy & KroshkaRu' }
        its(:kind) { should eq :fandub }
      end
    end

    context 'kind with colon' do
      let(:link) { 'http://www.animespirit.ru/anime/rs/series-rus/9504-samurai-flamenco-samuraj-flamenko.html' }

      context :video do
        subject { entry[:videos].find {|v| v.author == 'Gezell Studio' } }
        its(:kind) { should eq :fandub }
      end
    end

    context 'dorama ignore' do
      let(:link) { 'http://www.animespirit.ru/movies/dorama-rus/8325-velikij-uchitel-onidzuka-gto-great-teacher-onizuka.html' }
      its(:categories) { should eq ['Дорамы'] }
    end

    context 'live action ignore' do
      let(:link) { 'http://www.animespirit.ru/movies/laction-rus/9644-chelovek-so-zvezdy-you-who-came-from-the-stars.html' }
      its(:categories) { should eq ['Live action'] }
    end

    context 'special kind names' do
      let(:link) { 'http://www.animespirit.ru/anime/rs/ova-rus/1146-sladkie-kapelki-honey-x-honey-drops.html' }

      context :video do
        context :first do
          subject { entry[:videos].first }
          its(:episode) { should eq 1 }
          its(:kind) { should eq :subtitles }
          its(:author) { should be nil }
        end

        context :last do
          subject { entry[:videos].last }
          its(:episode) { should eq 2 }
          its(:kind) { should eq :fandub }
          its(:author) { should eq 'FaSt & Milirina' }
        end
      end
    end
  end
end
