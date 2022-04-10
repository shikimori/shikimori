describe WebmVideo do
  describe 'relations' do
    it { is_expected.to have_attached_file :thumbnail }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :url }
    # it { is_expected.to validate_uniqueness_of :url }
  end

  describe 'callbacks' do
    let(:video) { build :webm_video }
    before { allow(video).to receive :schedule_thumbnail }
    before { video.save }

    it { expect(video).to have_received :schedule_thumbnail }
  end

  describe 'aasm' do
    describe 'pending' do
      let(:video) { build :webm_video, :pending }
      it { expect(video).to be_can_process }
      it { expect(video).to be_can_to_failed }
    end

    describe 'processed' do
      let(:video) { build :webm_video, :processed }
      it { expect(video).to be_can_process }
      it { expect(video).to be_can_to_failed }
    end

    describe 'failed' do
      let(:video) { build :webm_video, :failed }
      it { expect(video).to be_can_process }
      it { expect(video).to be_can_to_failed }
    end
  end

  describe 'instance methods' do
    describe '#schedule_thumbnail' do
      let(:video) { build_stubbed :webm_video }
      before { allow(WebmThumbnail).to receive :perform_async }
      before { video.schedule_thumbnail }

      it { expect(WebmThumbnail).to have_received(:perform_async).with video.id }
    end
  end
end
