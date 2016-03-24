describe VideoExtractor::OpenGraphExtractor, vcr: { cassette_name: 'open_graph_video' } do
  let(:service) { VideoExtractor::OpenGraphExtractor.new url }

  describe 'fetch' do
    subject { service.fetch }

    context 'coub' do
      let(:url) { 'http://coub.com/view/bqn2pda' }

      its(:hosting) { is_expected.to eq :coub }
      its(:image_url) { is_expected.to eq '//ell.akamai.coub.com/get/bucket:32.11/p/coub/simple/cw_image/5539bc828be/56c75c0364d0a378cc3b9/med_1409156756_1381592378_00032.jpg' }
      its(:player_url) { is_expected.to eq '//c-cdn.coub.com/fb-player.swf?bot_type=unknown&coubID=bqn2pda' }
    end

    context 'twitch' do
      let(:url) { 'http://www.twitch.tv/joindotared/c/3661348' }

      its(:hosting) { is_expected.to eq :twitch }
      its(:image_url) { is_expected.to eq '//static-cdn.jtvnw.net/jtv_user_pictures/joindotared-profile_image-3280e012c28e251e-600x600.jpeg' }
      its(:player_url) { is_expected.to eq '//www-cdn.jtvnw.net/swflibs/TwitchPlayer.swf?channel=joindotared&playerType=facebook' }
    end

    context 'rutube' do
      let(:url) { 'http://rutube.ru/video/fb428243861964d3c9942e31b5f5a43a' }

      its(:hosting) { is_expected.to eq :rutube }
      its(:image_url) { is_expected.to eq '//pic.rutube.ru/video/d2/81/d281c126ac608e6f66642009f1be59e0.jpg' }
      its(:player_url) { is_expected.to eq '//rutube.ru/play/embed/6797624?isFullTab=true' }
    end

    context 'vimeo' do
      let(:url) { 'http://vimeo.com/85212054' }

      its(:hosting) { is_expected.to eq :vimeo }
      its(:image_url) { is_expected.to eq 'https://i.vimeocdn.com/video/463402969_1280x720.jpg' }
      its(:player_url) { is_expected.to eq 'https://player.vimeo.com/video/85212054' }
    end

    context 'myvi' do
      let(:url) { 'http://asia.myvi.ru/watch/Vojna-Magov_eQ4now9R-0KG9eoESX_N-A2' }

      its(:hosting) { is_expected.to eq :myvi }
      its(:image_url) { is_expected.to eq '//images.myvi.ru/animeicon/25/e6/58917.jpg' }
      its(:player_url) { is_expected.to eq '//myvi.ru/player/flash/oI_SgyRHWdMLI6UU2pmRESiY4Y-Ie0wAnu3jBetGxgY9wJFPgg4yJA4JzsT1kQ7a35LOr3hG3K7g1' }
    end

    context 'sibnet' do
      let(:url) { 'http://video.sibnet.ru/video1234982-03__Poverivshiy_v_grezyi' }

      its(:hosting) { is_expected.to eq :sibnet }
      its(:image_url) { is_expected.to eq '//video.sibnet.ru/upload/cover/video_1234982_0.jpg' }
      its(:player_url) { is_expected.to eq '//video.sibnet.ru/shell.swf?videoid=1234982' }

      context 'broken_video' do
        let(:url) { 'http://video.sibnet.ru/video996603-Kyou_no_Asuka_Show_1_5_serii__rus__sub_' }
        it { is_expected.to be_nil }
      end
    end

    #context 'yandex' do
      #let(:url) { 'http://video.yandex.ru/users/allod2008/view/78' }

      #its(:hosting) { is_expected.to eq :yandex }
      #its(:image_url) { is_expected.to eq 'http://static.video.yandex.ru/get/allod2008/khubzhabwp.1610/m320x240.jpg' }
      #its(:player_url) { is_expected.to eq 'http://static.video.yandex.ru/full-10/allod2008/khubzhabwp.1610/player.swf' }
    #end

    context 'dailymotion' do
      let(:url) { 'http://www.dailymotion.com/video/x1af42g_lupin-iii-vs-detective-conan-99radioservice-wonderland_shortfilms' }

      its(:hosting) { is_expected.to eq :dailymotion }
      its(:image_url) { is_expected.to eq '//s1.dmcdn.net/DeNs_/526x297-o88.jpg' }
      its(:player_url) { is_expected.to eq '//www.dailymotion.com/embed/video/x1af42g' }
    end

    context 'streamable' do
      let(:url) { 'https://streamable.com/efgm' }

      its(:hosting) { is_expected.to eq :streamable }
      its(:image_url) { is_expected.to eq '//cdn.streamable.com/image/efgm.jpg' }
      its(:player_url) { is_expected.to eq '//streamable.com/e/efgm' }
    end

    context 'invalid_url' do
      let(:url) { 'http://coub.cOOOm/view/bqn2pda' }
      it { is_expected.to be_nil }
    end
  end
end
