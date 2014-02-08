require 'spec_helper'

describe BbCodes::VkTag do
  let(:tag) { BbCodes::VkTag.instance }
  subject { tag.format text }

  describe :format do
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
