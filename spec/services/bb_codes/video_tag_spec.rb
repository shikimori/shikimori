describe BbCodes::VideoTag do
  let(:tag) { BbCodes::VideoTag.instance }

  describe '#format' do
    subject { tag.format text }

    context 'youtube' do
      let(:hash) { 'og2a5lngYeQ' }
      let(:time) { 22 }

      context 'without time' do
        let(:text) { "https://www.youtube.com/watch?v=#{hash}" }
        it { should include "data-href=\"http://youtube.com/embed/#{hash}\" href=\"http://youtube.com/watch?v=#{hash}\"" }
      end

      context 'with time' do
        let(:text) { "https://www.youtube.com/watch?v=#{hash}#t=#{time}" }
        it { should include "<a class=\"c-video b-video unprocessed youtube" }
        it { should include "data-href=\"http://youtube.com/embed/#{hash}?start=#{time}\" href=\"http://youtube.com/watch?v=#{hash}#t=#{time}\"" }
      end

      context 'with text' do
        let(:text) { "zzz https://www.youtube.com/watch?v=#{hash}" }
        it { should include "data-href=\"http://youtube.com/embed/#{hash}\" href=\"http://youtube.com/watch?v=#{hash}\"" }
      end

      context 'with params', vcr: { cassette_name: 'youtube' } do
        let(:text) { 'https://vk.com/video-61933528_167061553?hash=w4ertfg' }
        it { should match /\A<.*>\Z/ }
      end

      context 'bad url' do
        let(:text) { "https://www.youtube.co/watch?v=#{hash}" }
        it { should eq text }
      end
    end

    context 'vk', vcr: { cassette_name: 'vk_video' } do
      let(:oid) { '98023184' }
      let(:vid) { '165811692' }
      let(:hash2) { '6d9a4c5f93270892' }

      context 'without text' do
        let(:text) { "http://vk.com/video#{oid}_#{vid}" }
        it { should include "<a class=\"c-video b-video unprocessed vk" }
        it { should include "data-href=\"https://vk.com/video_ext.php?oid=#{oid}&amp;id=#{vid}&amp;hash=#{hash2}&amp;hd=1\" href=\"http://vk.com/video#{oid}_#{vid}\"" }
      end

      context 'width text' do
        let(:text) { "zzz http://vk.com/video#{oid}_#{vid}" }
        it { should include 'zzz <a class="' }
      end

      context 'private video' do
        let(:text) { 'http://vk.com/video17174270_167070090' }
        it { should eq text }
      end
    end

    context 'open_graph', vcr: { cassette_name: 'open_graph_video' } do
      context 'coub' do
        let(:text) { 'http://coub.com/view/bqn2pda' }
        it { should include "<a class=\"c-video b-video unprocessed coub" }
      end

      context 'twitch' do
        let(:text) { 'http://www.twitch.tv/joindotared/c/3661348' }
        it { should include "<a class=\"c-video b-video unprocessed twitch" }
      end

      context 'rutube' do
        let(:text) { 'http://rutube.ru/video/fb428243861964d3c9942e31b5f5a43a' }
        it { should include "<a class=\"c-video b-video unprocessed rutube" }
      end

      context 'vimeo' do
        let(:text) { 'http://vimeo.com/85212054' }
        it { should include "<a class=\"c-video b-video unprocessed vimeo" }
      end

      context 'myvi' do
        let(:text) { 'http://asia.myvi.ru/watch/Vojna-Magov_eQ4now9R-0KG9eoESX_N-A2' }
        it { should include "<a class=\"c-video b-video unprocessed myvi" }
      end

      context 'sibnet' do
        let(:text) { 'http://video.sibnet.ru/video1234982-03__Poverivshiy_v_grezyi' }
        it { should include "<a class=\"c-video b-video unprocessed sibnet" }
      end

      context 'yandex' do
        let(:text) { 'http://video.yandex.ru/users/allod2008/view/78' }
        it { should include "<a class=\"c-video b-video unprocessed yandex" }
      end

      context 'dailymotion' do
        context 'common url' do
          let(:text) { 'http://www.dailymotion.com/video/x19jwj5_boku-wa-tomodachi-ga-sukunai-op-ed-creditless_shortfilms?search_algo=1' }
          it { should include "<a class=\"c-video b-video unprocessed dailymotion" }
          it { should match /\A<.*>\Z/ }
        end

        context 'special url' do
          let(:text) { "http://dailymotion.com/video/x1cbf83_детектив-конан-фильм-18-снайпер-из-другого-измерения_shortfilms" }
          it { should include "<a class=\"c-video b-video unprocessed dailymotion" }
          it { should match %r{</a>$} }
        end
      end

      context 'sibnet' do
        let(:text) { 'http://video.sibnet.ru/video1234982-03__Poverivshiy_v_grezyi' }
        it { should include "<a class=\"c-video b-video unprocessed sibnet" }
      end
    end
  end

  describe '#preprocess' do
    subject { tag.preprocess text }
    let(:url) { "https://www.youtube.com/watch?v=GFhdjskj#t=123" }
    let(:text) { "[url=#{url}]test[/url][url=#{url}]test[/url]" }

    it { should eq "#{url} #{url} " }
  end
end
