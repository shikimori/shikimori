describe Topics::DecomposeBody do
  let(:service) { Topics::DecomposeBody.new topic }
  let(:topic) { build :topic, body: body }

  let(:body) { "test[image=#{image_1.id}]\
[wall]\
[video=#{video.id}]\
[image=#{image_2.id}]\
[image=#{image_3.id}]\
[/wall]" }

  let(:image_1) { create :user_image }
  let(:image_2) { create :user_image }
  let(:image_3) { create :user_image }
  let(:video) { create :video }

  describe '#wall_video' do
    it { expect(service.wall_video).to eq video }
  end

  describe '#wall_images' do
    it { expect(service.wall_images).to eq [image_2, image_3] }
  end
end
