describe WebmThumbnail do
  let(:worker) { WebmThumbnail.new }
  let(:webm_video) { create :webm_video, :pending }

  before { allow(worker).to receive :grab_thumbnail }
  before { worker.perform webm_video.id }

  it { expect(webm_video.reload).to be_failed }
end
