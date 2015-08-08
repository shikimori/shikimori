describe Version do
  describe 'relations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to :moderator }
    it { is_expected.to belong_to :item }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :item }
    it { is_expected.to validate_presence_of :item_diff }
  end

  describe 'state_machine' do
    let(:anime) { create :anime }
    let(:video) { create :anime_video, anime: anime, episode: 2 }
    let(:diff_hash) {{ episode: [1,2] }}
    let(:version) { create :version_anime_video, item_id: video.id, item_diff: diff_hash, state: state }

    subject { version }

    describe '#accept' do
      before { version.accept }

      describe 'from accepted_pending' do
        let(:state) { :accepted_pending }
        it { is_expected.to be_accepted }
        specify { expect(video.reload.episode).to eq 2 }
      end

      describe 'from pending' do
        let(:state) { :pending }
        it { is_expected.to be_accepted }
        specify { expect(video.reload.episode).to eq 2 }
      end
    end

    describe '#reject' do
      before { version.reject }

      describe 'from accepted_pending' do
        let(:state) { :accepted_pending }
        subject { version }
        it { is_expected.to be_rejected }
        specify { expect(video.reload.episode).to eq 1 }
      end

      describe 'from pending' do
        let(:state) { :pending }
        it { is_expected.to be_rejected }
        specify { expect(video.reload.episode).to eq 1 }
      end
    end
  end
end
