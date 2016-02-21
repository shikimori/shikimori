describe Topics::ComposeBody do
  let(:service) { Topics::ComposeBody.new params }
  let :params do
    {
      body: body,
      wall_ids: wall_ids,
      video_id: video_id
    }
  end
  let(:body) { 'test' }
  let(:wall_ids) { }
  let(:video_id) { }

  subject { service.call }

  describe '#call' do
    it { is_expected.to eq body }

    context 'images' do
      let(:user_image) { create :user_image }
      let(:wall_ids) { [user_image.id.to_s] }

      it { is_expected.to eq "#{body}[wall][image=#{user_image.id}][/wall]" }
      # it do
        # is_expected.to eq "#{body}\
# [wall]\
# [url=#{ImageUrlGenerator.instance.url user_image, :original}][poster=#{user_image.id}][/url]\
# [/wall]"
      # end
    end

    context 'video' do
      let(:video) { create :video }
      let(:video_id) { video.id.to_s }
      it { is_expected.to eq "#{body}[wall][video=#{video.id}][/wall]" }
    end

    context 'images + video' do
      let(:user_image) { create :user_image }
      let(:video) { create :video }

      let(:wall_ids) { [user_image.id.to_s] }
      let(:video_id) { video.id.to_s }

      it { is_expected.to eq "#{body}[wall][video=#{video.id}][image=#{user_image.id}][/wall]" }
      # it do
        # is_expected.to eq "#{body}\
# [wall]\
# [video=#{video.id}]\
# [url=#{ImageUrlGenerator.instance.url user_image, :original}][poster=#{user_image.id}][/url]\
# [/wall]"
      # end
    end
  end
end
