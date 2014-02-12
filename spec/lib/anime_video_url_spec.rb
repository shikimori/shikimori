require 'spec_helper'

describe AnimeVideoUrl do
  describe :extract do
    subject(:extract) { AnimeVideoUrl.new(url).extract }

    context :direct do
      let(:url) { 'http://vk.com/video_ext.php?oid=-11230840&id=164793125&hash=c8f8109b2c0341d7' }
      it { should eq url }
    end

    context :short do
      subject { VCR.use_cassette(:vk_video) { extract } }

      context :with_dash do
        let(:url) { 'http://vk.com/video-42313379_167267838' }
        let(:extracted_url) { 'https://vk.com/video_ext.php?oid=-42313379&id=167267838&hash=a941d75eea176ded&hd=1' }

        it { should eq extracted_url }
      end

      context :without_dash do
        let(:url) { 'https://vk.com/video135375095_163446262' }
        let(:extracted_url) { 'https://vk.com/video_ext.php?oid=135375095&id=163446262&hash=8574b5f5752c28d4&hd=1' }

        it { should eq extracted_url }
      end
    end

    context :frame do
      let(:url) { '<iframe width="607" src="'+extracted_url+'" height="360" frameborder="0"></iframe>' }
      let(:extracted_url) { 'http://vk.com/video_ext.php?oid=-42313379&id=167267838&hash=a941d75eea176ded&hd=1' }
      it { should eq extracted_url }
    end

    context :strip do
      let(:url) { ' http://vk.com/video_1 ' }
      it { should eq url.strip }
    end
  end
end
