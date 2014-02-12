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
  end

  describe :preprocess do
    subject { tag.preprocess text }
    let(:url) { "https://www.youtube.com/watch?v=GFhdjskj#t=123" }
    let(:text) { "[url=#{url}]test[/url][url=#{url}]test[/url]" }

    it { should eq "#{url} #{url} " }
  end
end
