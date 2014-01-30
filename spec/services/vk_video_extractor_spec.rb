require 'spec_helper'

describe VkVideoExtractor do
  let(:service) { VkVideoExtractor.new url }

  describe :fetch do
    subject { service.fetch }
    before { VCR.use_cassette(:vk_video) { subject } }

    context :valid_url do
      let(:url) { 'http://vk.com/video98023184_165811692' }

      its(:image_url) { should eq 'http://cs514511.vk.me/u98023184/video/l_81cce630.jpg' }
      its(:oid) { should be 98023184 }
      its(:vid) { should be 165811692 }
      its(:hash2) { should eq '6d9a4c5f93270892' }
    end

    context :invalid_url do
      let(:url) { 'http://vk.com/video98023184_165811692zzz' }
      it { should be_nil }
    end
  end
end
