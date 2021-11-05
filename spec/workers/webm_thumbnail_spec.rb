describe WebmThumbnail do
  let(:worker) { described_class.new }
  let(:webm_video) { create :webm_video, :pending, url: 'https://test.com;sudo ls' }

  before do
    allow(worker).to receive(:thumbnail_path).and_return "/tmp/#{rand}"
    allow(worker).to receive :grab_thumbnail
  end
  subject! { worker.perform webm_video.id }

  it do
    expect(worker)
      .to have_received(:grab_thumbnail)
      .with(Shellwords.shellescape(webm_video.url), any_args)
    expect(webm_video.reload).to be_failed
  end
end
