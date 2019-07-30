describe Topics::ComposeBody do
  subject { Topics::ComposeBody.call params }

  let(:params) do
    {
      body: body,
      wall_ids: wall_ids,
      video_id: video_id,
      source: source
    }
  end
  let(:body) { 'test' }
  let(:wall_ids) {}
  let(:video_id) {}
  let(:source) { [nil, ''].sample }

  it { is_expected.to eq body }

  context 'images' do
    let(:user_image) { create :user_image }
    let(:wall_ids) { [user_image.id.to_s] }

    it { is_expected.to eq "#{body}[wall][wall_image=#{user_image.id}][/wall]" }
  end

  context 'video' do
    let(:video) { create :video }
    let(:video_id) { video.id.to_s }
    it { is_expected.to eq "#{body}[wall][video=#{video.id}][/wall]" }
  end

  context 'source' do
    let(:source) { 'https://zxc.org' }
    it { is_expected.to eq "#{body}[source]https://zxc.org[/source]" }
  end

  context 'all together' do
    let(:user_image) { create :user_image }
    let(:video) { create :video }
    let(:source) { 'https://zxc.org' }

    let(:wall_ids) { [user_image.id.to_s] }
    let(:video_id) { video.id.to_s }

    it do
      is_expected.to eq(
        "#{body}[wall][video=#{video.id}][wall_image=#{user_image.id}][/wall][source]https://zxc.org[/source]"
      )
    end
  end
end
