describe BbCodes::Tags::VideoUrlTag, :vcr do
  let(:tag) { BbCodes::Tags::VideoUrlTag.instance }

  describe '#format' do
    subject { tag.format text }

    context 'youtube' do
      let(:hash) { 'og2a5lngYeQ' }
      let(:text) { "https://www.youtube.com/watch?v=#{hash}" }

      it { is_expected.to include "data-href=\"//youtube.com/embed/#{hash}\" href=\"https://youtube.com/watch?v=#{hash}\"" }

      context 'with text' do
        let(:text) { "zzz https://www.youtube.com/watch?v=#{hash}" }
        it { is_expected.to include "data-href=\"//youtube.com/embed/#{hash}\" href=\"https://youtube.com/watch?v=#{hash}\"" }
      end

      # context 'with params' do
      #   let(:text) { 'https://vk.com/video-61933528_167061553?hash=w4ertfg' }
      #   it { is_expected.to match(/\A<.*>\Z/) }
      # end

      context 'bad url' do
        let(:text) { "https://www.youtube.co/watch?v=#{hash}" }
        it { is_expected.to eq text }
      end

      context 'wrapped in url' do
        let(:text) { "[url]https://www.youtube.com/watch?v=#{hash}[/url]" }
        it { is_expected.to eq text }
      end
    end

    context 'vk' do
      let(:oid) { '98023184' }
      let(:vid) { '165811692' }
      let(:hash2) { '6d9a4c5f93270892' }

      context 'without text' do
        let(:text) { "http://vk.com/video#{oid}_#{vid}" }
        it { is_expected.to include '<div class="c-video b-video unprocessed vk' }
        it { is_expected.to include "data-href=\"//vk.com/video_ext.php?oid=#{oid}&amp;id=#{vid}&amp;hash=#{hash2}\" href=\"https://vk.com/video#{oid}_#{vid}\"" }
      end

      context 'width text' do
        let(:text) { "zzz http://vk.com/video#{oid}_#{vid}" }
        it { is_expected.to include 'zzz <div class="' }
      end

      context 'private video' do
        let(:text) { 'http://vk.com/video17174270_167070090' }
        it { is_expected.to eq text }
      end
    end

    context 'open_graph' do
      context 'coub' do
        let(:text) { 'http://coub.com/view/bqn2pda' }
        it { is_expected.to include '<div class="c-video b-video unprocessed coub' }
      end

      # context 'twitch' do
      #   let(:text) { 'https://www.twitch.tv/videos/266180202' }
      #   it { is_expected.to include '<div class="c-video b-video unprocessed twitch' }
      # end

      context 'rutube' do
        let(:text) { 'http://rutube.ru/video/fb428243861964d3c9942e31b5f5a43a' }
        it { is_expected.to include '<div class="c-video b-video unprocessed rutube' }
      end

      context 'vimeo' do
        let(:text) { 'http://vimeo.com/85212054' }
        it { is_expected.to include '<div class="c-video b-video unprocessed vimeo' }
      end

      context 'sibnet' do
        let(:text) { 'http://video.sibnet.ru/video1234982-03__Poverivshiy_v_grezyi' }
        it { is_expected.to include '<div class="c-video b-video unprocessed sibnet' }
      end

      # context 'yandex' do
        # let(:text) { 'http://video.yandex.ru/users/allod2008/view/78' }
        # it { is_expected.to include "<div class=\"c-video b-video unprocessed yandex" }
      # end

      # context 'dailymotion' do
        # context 'common url' do
          # let(:text) { 'http://www.dailymotion.com/video/x19jwj5_boku-wa-tomodachi-ga-sukunai-op-ed-creditless_shortfilms?search_algo=1' }
          # it { is_expected.to include '<div class="c-video b-video unprocessed dailymotion' }
          # it { is_expected.to match(/\A<.*>\Z/) }
        # end

        # context 'special url' do
          # let(:text) { 'http://dailymotion.com/video/x1cbf83_детектив-конан-фильм-18-снайпер-из-другого-измерения_shortfilms' }
          # it { is_expected.to include '<div class="c-video b-video unprocessed dailymotion' }
          # it { is_expected.to match %r{</div>$} }
        # end
      # end

      context 'streamable' do
        let(:text) { 'https://streamable.com/efgm' }
        it { is_expected.to include '<div class="c-video b-video unprocessed streamable' }
      end

      context 'myvi' do
        let(:text) { 'https://www.myvi.top/idaofy?v=kcptso3b1mpr8n8fc3xyof5tyh' }
        it { is_expected.to include '<div class="c-video b-video unprocessed myvi' }
      end
    end

    context 'ok' do
      let(:text) { 'https://ok.ru/videoembed/815923404420' }
      it { is_expected.to include '<div class="c-video b-video unprocessed ok' }
    end

    context 'youmite' do
      let(:text) { 'https://video.youmite.ru/embed/JIzidma8NwTMu8m' }
      it { is_expected.to include '<div class="c-video b-video unprocessed youmite' }
    end

    context 'viuly' do
      let(:text) { 'https://viuly.io/video/video-of-the-company-bizzilion.-start-making-money-on-television--online-broadcasts-with-bizzilion-2138479' }
      it { is_expected.to include '<div class="c-video b-video unprocessed viuly' }
    end

    context 'stormo' do
      let(:text) { 'https://stormo.xyz/videos/415088/risuem-abstraktnye-cvety-verevkoy-i-cepyu/' }
      it { is_expected.to include '<div class="c-video b-video unprocessed stormo' }
    end

    describe 'around tags' do
      let(:text) { '[div]https://www.youtube.com/watch?v=J_eyR0tR9gI[/div]' }
      it { is_expected.to include '[div]<div class="c-video b-video' }
    end
  end

  describe '#preprocess' do
    subject { tag.preprocess text }
    let(:url) { 'https://www.youtube.com/watch?v=GFhdjskj#t=123' }
    let(:text) { "[url=#{url}]test[/url][url=#{url}]test[/url]" }

    it { is_expected.to eq "#{url} #{url} " }
  end
end
