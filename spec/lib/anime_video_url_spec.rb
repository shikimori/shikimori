require 'spec_helper'

describe AnimeVideoUrl do
  describe :extract do
    subject { AnimeVideoUrl.new(url).extract }

    context :direct do
      let(:url) { 'http://vk.com/video_ext.php?oid=-11230840&id=164793125&hash=c8f8109b2c0341d7' }
      it { should eq url }
    end

    context :short do
      before { Video.any_instance.stub(:direct_url).and_return extracted_url }
      let(:url) { 'http://vk.com/video-42313379_167267838' }
      let(:extracted_url) { 'https://vk.com/video_ext.php?oid=-42313379&id=167267838&hash=a941d75eea176ded&hd=1' }

      it { should eq extracted_url }
    end

    context :frame do
      let(:extracted_url) { 'http://vk.com/video_ext.php?oid=-42313379&id=167267838&hash=a941d75eea176ded&hd=1' }
      let(:url) { '<iframe src="'+extracted_url+'" width="607" height="360" frameborder="0"></iframe>' }
      it { should eq extracted_url }
    end

    context :strip do
      let(:url) { ' http://vk.com/video_1 ' }
      it { should eq url.strip }
    end
  end
end
