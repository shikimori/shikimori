require 'spec_helper'

describe AnimeVideoComplaintDecorator do
  let(:decorator) { AnimeVideoComplaintDecorator.new message }
  let(:message) { build :message, body: "Пожаловались на видео id:#{id} [broken_video] #{url}" }
  let(:url) { 'http://animeonline.dev/videos/79/1/2519' }
  let(:id) { 2519 }

  describe :video_id do
    subject { decorator.video_id }
    it { should eq id }
  end

  describe :video_url do
    subject { decorator.video_url }
    it { should eq url }
  end
end
