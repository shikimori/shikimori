describe VideoExtractor::OpenGraphExtractor do
  let(:service) { VideoExtractor::OpenGraphExtractor.new url }

  describe :fetch do
    subject { service.fetch }
    before { VCR.use_cassette(:open_graph_video) { subject } }

    context :coub do
      let(:url) { 'http://coub.com/view/bqn2pda' }

      its(:hosting) { should eq :coub }
      its(:image_url) { should eq 'http://cdn1.akamai.coub.com/coub/simple/cw_image/5539bc828be/56c75c0364d0a378cc3b9/timeline_1381592378_00032.jpg' }
      its(:player_url) { should eq 'http://c-cdn.coub.com/fb-player.swf?coubID=bqn2pda' }
    end

    context :twitch do
      let(:url) { 'http://www.twitch.tv/joindotared/c/3661348' }

      its(:hosting) { should eq :twitch }
      its(:image_url) { should eq 'http://static-cdn.jtvnw.net/jtv.thumbs/archive-500512971-630x473.jpg' }
      its(:player_url) { should eq 'http://secure.twitch.tv/swflibs/TwitchPlayer.swf?videoId=c3661348&playerType=facebook' }
    end

    context :rutube do
      let(:url) { 'http://rutube.ru/video/fb428243861964d3c9942e31b5f5a43a' }

      its(:hosting) { should eq :rutube }
      its(:image_url) { should eq 'http://pic.rutube.ru/video/d2/81/d281c126ac608e6f66642009f1be59e0.jpg' }
      its(:player_url) { should eq 'http://video.rutube.ru/6797624' }
    end

    context :vimeo do
      let(:url) { 'http://vimeo.com/85212054' }

      its(:hosting) { should eq :vimeo }
      its(:image_url) { should eq 'http://b.vimeocdn.com/ts/463/402/463402969_1280.jpg' }
      its(:player_url) { should eq 'http://vimeo.com/moogaloop.swf?clip_id=85212054' }
    end

    context :myvi do
      let(:url) { 'http://asia.myvi.ru/watch/Vojna-Magov_eQ4now9R-0KG9eoESX_N-A2' }

      its(:hosting) { should eq :myvi }
      its(:image_url) { should eq 'http://images.myvi.ru/animeicon/25/e6/58917.jpg' }
      its(:player_url) { should eq 'http://myvi.ru/player/flash/oI_SgyRHWdMLI6UU2pmRESiY4Y-Ie0wAnu3jBetGxgY9wJFPgg4yJAyvz_PY1mzRg1SqIreeFh7U1' }
    end

    context :sibnet do
      let(:url) { 'http://video.sibnet.ru/video1234982-03__Poverivshiy_v_grezyi' }

      its(:hosting) { should eq :sibnet }
      its(:image_url) { should eq 'http://video.sibnet.ru/upload/cover/video_1234982_0.jpg' }
      its(:player_url) { should eq 'http://video.sibnet.ru/shell.swf?videoid=1234982' }

      context :broken_video do
        let(:url) { 'http://video.sibnet.ru/video996603-Kyou_no_Asuka_Show_1_5_serii__rus__sub_' }
        it { should be_nil }
      end
    end

    context :yandex do
      let(:url) { 'http://video.yandex.ru/users/allod2008/view/78' }

      its(:hosting) { should eq :yandex }
      its(:image_url) { should eq 'http://static.video.yandex.ru/get/allod2008/khubzhabwp.1610/2.320x240.jpg' }
      its(:player_url) { should eq 'http://static.video.yandex.ru/full-10/allod2008/khubzhabwp.1610/player.swf' }
    end

    context :dailymotion do
      let(:url) { 'http://dailymotion.com/video/x1cbf83_детектив-конан-фильм-18-снайпер-из-другого-измерения_shortfilms' }

      its(:hosting) { should eq :dailymotion }
      its(:image_url) { should eq 'http://s1.dmcdn.net/DpbbQ/526x297-l8K.jpg' }
      its(:player_url) { should eq 'http://www.dailymotion.com/swf/video/x1cbf83?autoPlay=1' }
    end

    context :invalid_url do
      let(:url) { 'http://coub.cOOOm/view/bqn2pda' }
      it { should be_nil }
    end
  end
end
