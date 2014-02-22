require 'spec_helper'

describe BbCodes::VideoTag do
  let(:tag) { BbCodes::VideoTag.instance }

  describe :format do
    subject { tag.format text }

    context :youtube do
      let(:hash) { 'og2a5lngYeQ' }
      let(:time) { 22 }

      context 'without time' do
        let(:text) { "https://www.youtube.com/watch?v=#{hash}" }
        it { should include "<div class=\"image-container video youtube\"" }
        it { should include "a data-href=\"http://youtube.com/v/#{hash}\" href=\"http://youtube.com/watch?v=#{hash}\"" }
      end

      context 'with time' do
        let(:text) { "https://www.youtube.com/watch?v=#{hash}#t=#{time}" }
        it { should include "<div class=\"image-container video youtube\"" }
        it { should include "a data-href=\"http://youtube.com/v/#{hash}?start=#{time}\" href=\"http://youtube.com/watch?v=#{hash}#t=#{time}\"" }
      end

      context 'with text' do
        let(:text) { "zzz https://www.youtube.com/watch?v=#{hash}" }
        it { should include "zzz <div class=\"image-container video youtube\"" }
        it { should include "a data-href=\"http://youtube.com/v/#{hash}\" href=\"http://youtube.com/watch?v=#{hash}\"" }
      end

      context 'with params' do
        let(:text) { 'https://vk.com/video-61933528_167061553?hash=w4ertfg' }
        it { should match /\A<.*>\Z/ }
      end

      context 'bad url' do
        let(:text) { "https://www.youtube.co/watch?v=#{hash}" }
        it { should eq text }
      end
    end

    context :vk do
      let(:oid) { '98023184' }
      let(:vid) { '165811692' }
      let(:hash2) { '6d9a4c5f93270892' }
      before { VCR.use_cassette(:vk_video) { subject } }

      context 'without text' do
        let(:text) { "http://vk.com/video#{oid}_#{vid}" }
        it { should include '<div class="image-container video vk"' }
        it { should include "a data-href=\"https://vk.com/video_ext.php?oid=#{oid}&amp;id=#{vid}&amp;hash=#{hash2}&amp;hd=1\" href=\"http://vk.com/video#{oid}_#{vid}\"" }
      end

      context 'width text' do
        let(:text) { "zzz http://vk.com/video#{oid}_#{vid}" }
        it { should include 'zzz <div class="image-container video vk"' }
      end

      context 'private video' do
        let(:text) { 'http://vk.com/video17174270_167070090' }
        it { should eq text }
      end
    end

    context :open_graph do
      before { VCR.use_cassette(:open_graph_video) { subject } }

      context :coub do
        let(:text) { 'http://coub.com/view/bqn2pda' }
        it { should include '<div class="image-container video coub"' }
      end

      context :twitch do
        let(:text) { 'http://www.twitch.tv/joindotared/c/3661348' }
        it { should include '<div class="image-container video twitch"' }
      end

      context :rutube do
        let(:text) { 'http://rutube.ru/video/fb428243861964d3c9942e31b5f5a43a' }
        it { should include '<div class="image-container video rutube"' }
      end

      context :vimeo do
        let(:text) { 'http://vimeo.com/85212054' }
        it { should include '<div class="image-container video vimeo"' }
      end

      context :myvi do
        let(:text) { 'http://asia.myvi.ru/watch/Vojna-Magov_eQ4now9R-0KG9eoESX_N-A2' }
        it { should include '<div class="image-container video myvi"' }
      end

      context :sibnet do
        let(:text) { 'http://video.sibnet.ru/video1234982-03__Poverivshiy_v_grezyi' }
        it { should include '<div class="image-container video sibnet"' }
      end

      context :yandex do
        let(:text) { 'http://video.yandex.ru/users/allod2008/view/78' }
        it { should include '<div class="image-container video yandex"' }
      end

      context :dailymotion do
        let(:text) { 'http://www.dailymotion.com/video/x19jwj5_boku-wa-tomodachi-ga-sukunai-op-ed-creditless_shortfilms?search_algo=1' }
        it { should include '<div class="image-container video dailymotion"' }
        it { should match /\A<.*>\Z/ }
      end

      context :sibnet do
        let(:text) { 'http://video.sibnet.ru/video1234982-03__Poverivshiy_v_grezyi' }
        it { should include '<div class="image-container video sibnet"' }
      end
    end
  end

  describe :preprocess do
    subject { tag.preprocess text }
    let(:url) { "https://www.youtube.com/watch?v=GFhdjskj#t=123" }
    let(:text) { "[url=#{url}]test[/url][url=#{url}]test[/url]" }

    it { should eq "#{url} #{url} " }
  end
end
