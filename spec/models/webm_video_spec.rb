describe WebmVideo do
  describe 'relations' do
    it { is_expected.to have_attached_file :thumbnail }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :url }
    # it { is_expected.to validate_uniqueness_of :url }
  end

  describe 'aasm' do
    subject { build :webm_video, state }

    context 'pending' do
      let(:state) { Types::WebmVideo::State[:pending] }

      it { is_expected.to have_state state }
      it { is_expected.to allow_transition_to :processed }
      it { is_expected.to transition_from(state).to(:processed).on_event(:process) }
      it { is_expected.to allow_transition_to :failed }
      it { is_expected.to transition_from(state).to(:failed).on_event(:to_failed) }
    end

    context 'processed' do
      let(:state) { Types::WebmVideo::State[:processed] }

      it { is_expected.to_not allow_transition_to :pending }
      it { is_expected.to allow_transition_to :failed }
      it { is_expected.to transition_from(state).to(:failed).on_event(:to_failed) }
    end

    context 'failed' do
      let(:state) { Types::WebmVideo::State[:failed] }

      it { is_expected.to have_state state }
      it { is_expected.to_not allow_transition_to :pending }
      it { is_expected.to allow_transition_to :processed }
      it { is_expected.to transition_from(state).to(:processed).on_event(:process) }
    end
  end

  describe 'callbacks' do
    let(:video) { build :webm_video }
    before { allow(video).to receive :schedule_thumbnail }
    subject! { video.save }

    it { expect(video).to have_received :schedule_thumbnail }
  end

  describe 'instance methods' do
    describe '#schedule_thumbnail' do
      let(:video) { build_stubbed :webm_video }
      before { allow(WebmThumbnail).to receive :perform_async }
      subject! { video.send :schedule_thumbnail }

      it { expect(WebmThumbnail).to have_received(:perform_async).with video.id }
    end
  end
end
