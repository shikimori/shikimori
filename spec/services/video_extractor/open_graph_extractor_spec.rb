describe VideoExtractor::OpenGraphExtractor, :vcr do
  let(:service) { described_class.instance }

  describe '#fetch' do
    subject { service.fetch url }

    # context 'twitch' do
    #   context do
    #     let(:url) { 'http://www.twitch.tv/joindotared/c/3661348' }

    #     its(:hosting) { is_expected.to eq 'twitch' }
    #     its(:image_url) { is_expected.to eq '//static-cdn.jtvnw.net/jtv_user_pictures/joindotared-profile_image-3280e012c28e251e-600x600.jpeg' }
    #     its(:player_url) { is_expected.to eq '//www-cdn.jtvnw.net/swflibs/TwitchPlayer.swf?channel=joindotared&playerType=facebook' }
    #   end

    #   context do
    #     let(:url) { 'https://www.twitch.tv/videos/168874638' }

    #     its(:hosting) { is_expected.to eq 'twitch' }
    #     its(:image_url) { is_expected.to eq '//static-cdn.jtvnw.net/s3_vods/f5d8e3520fc389dac129_pterotactical_26073628016_698271942//thumb/thumb168874638-480x320.jpg' }
    #     its(:player_url) { is_expected.to eq '//player.twitch.tv/?video=v168874638&player=twitter&autoplay=false' }
    #   end
    # end

    # context 'myvi' do
    #   let(:url) { 'http://asia.myvi.ru/watch/Vojna-Magov_eQ4now9R-0KG9eoESX_N-A2' }

    #   its(:hosting) { is_expected.to eq 'myvi' }
    #   its(:image_url) { is_expected.to eq '//images.myvi.ru/animeicon/25/e6/58917.jpg' }
    #   its(:player_url) { is_expected.to eq '//myvi.ru/player/flash/oI_SgyRHWdMLI6UU2pmRESiY4Y-Ie0wAnu3jBetGxgY9wJFPgg4yJA4JzsT1kQ7a35LOr3hG3K7g1' }
    # end

    context 'sibnet' do
      let(:url) { 'http://video.sibnet.ru/video1234982-03__Poverivshiy_v_grezyi' }

      its(:hosting) { is_expected.to eq :sibnet }
      it do
        is_expected.to have_attributes(
          hosting: :sibnet,
          image_url: '//video.sibnet.ru/upload/cover/video_1234982_0.jpg',
          player_url: '//video.sibnet.ru/shell.php?videoid=1234982'
        )
      end

      context 'broken_video' do
        let(:url) { 'http://video.sibnet.ru/video996603-Kyou_no_Asuka_Show_1_5_serii__rus__sub_' }
        it { is_expected.to be_nil }
      end

      context 'embed url' do
        let(:url) { 'https://video.sibnet.ru/shell.php?videoid=1234982' }

        it do
          is_expected.to have_attributes(
            hosting: :sibnet,
            image_url: '//video.sibnet.ru/upload/cover/video_1234982_0.jpg',
            player_url: '//video.sibnet.ru/shell.php?videoid=1234982'
          )
        end
      end
    end

    # context 'yandex' do
      # let(:url) { 'http://video.yandex.ru/users/allod2008/view/78' }

      # its(:hosting) { is_expected.to eq 'yandex' }
      # its(:image_url) { is_expected.to eq 'http://static.video.yandex.ru/get/allod2008/khubzhabwp.1610/m320x240.jpg' }
      # its(:player_url) { is_expected.to eq 'http://static.video.yandex.ru/full-10/allod2008/khubzhabwp.1610/player.swf' }
    # end

    # context 'streamable' do
    #   let(:url) { 'https://streamable.com/efgm' }
    #
    #   its(:hosting) { is_expected.to eq 'streamable' }
    #   its(:image_url) do
    #     is_expected.to eq(
    #       '//cdn-b-west.streamable.com/image/efgm.jpg?token=QCb8UD4UEV-VNMDaD7gGhA&expires=1527731420'
    #     )
    #   end
    #   its(:player_url) { is_expected.to eq '//streamable.com/t/efgm' }
    # end

    # context 'youmite' do
    #   let(:url) { 'https://video.youmite.ru/embed/JIzidma8NwTMu8m' }
    #
    #   its(:hosting) { is_expected.to eq 'youmite' }
    #   its(:image_url) do
    #     is_expected.to eq(
    #       '//video.youmite.ru/upload/photos/2019/02/c919b5968940f38c9bc790f40b80d52143a64ef5ObfFlhjplbdoGKbdEKEX.video_thumb_8584_936.jpeg'
    #     )
    #   end
    #   its(:player_url) { is_expected.to eq '//video.youmite.ru/embed/JIzidma8NwTMu8m' }
    # end

    # describe 'viuly' do
    #   let(:url) { 'https://viuly.io/video/video-of-the-company-bizzilion.-start-making-money-on-television--online-broadcasts-with-bizzilion-2138479' }
    #   its(:hosting) { is_expected.to eq 'viuly' }
    #   its(:image_url) do
    #     is_expected.to eq(
    #       '//cdn3.viuly.io/v2/uploads/images/2089/medium/70035_1550697662_001.jpg'
    #     )
    #   end
    #   its(:player_url) { is_expected.to eq '//viuly.io/embed/video-of-the-company-bizzilion.-start-making-money-on-television--online-broadcasts-with-bizzilion-2138479' }
    # end

    # describe 'stormo' do
    #   let(:url) { 'https://stormo.xyz/videos/245/stiv-djobs/' }
    #   its(:hosting) { is_expected.to eq 'stormo' }
    #   its(:image_url) do
    #     is_expected.to eq(
    #       '//stormo.xyz/contents/videos_screenshots/0/245/preview.mp4.jpg'
    #     )
    #   end
    #   its(:player_url) { is_expected.to eq '//stormo.xyz/embed/245/' }
    # end

    # describe 'mediafile.online' do
    #   let(:url) { 'https://mediafile.online/video/176446/bolshoy-sobachiy-pobeg-treyler-2016/' }
    #   its(:hosting) { is_expected.to eq 'mediafile' }
    #   its(:image_url) do
    #     is_expected.to eq(
    #       '//mediafile.online/contents/videos_screenshots/176000/176446/preview.mp4.jpg'
    #     )
    #   end
    #   its(:player_url) { is_expected.to eq '//mediafile.online/embed/176446/' }
    # end

    context 'invalid_url' do
      let(:url) { 'http://coub.cOOOm/view/bqn2pda' }
      it { is_expected.to be_nil }
    end
  end
end
