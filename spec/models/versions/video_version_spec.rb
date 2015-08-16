describe Versions::VideoVersion do
  describe '#action' do
    let(:version) { build :video_version, item_diff: { action: 'upload' } }
    it { expect(version.action).to eq 'upload' }
  end

  describe '#video' do
    let(:video) { create :video }

    let(:version) { build :video_version, item_diff: { videos: [video.id] } }
    it { expect(version.video).to eq video }
  end

  describe '#apply_changes' do
    let(:version) { build :video_version,
      item_diff: { action: action, videos: [video.id] } }

    context 'upload' do
      let(:video) { create :video, :uploaded }
      let(:action) { 'upload' }
      before { version.apply_changes }

      it { expect(video.reload).to be_confirmed }
    end

    context 'delete' do
      let(:video) { create :video, :confirmed }
      let(:action) { 'delete' }
      before { version.apply_changes }

      it { expect(video.reload).to be_deleted }
    end

    context 'unknown action' do
      let(:video) { build_stubbed :video }
      let(:action) { 'zzz' }
      it { expect{version.apply_changes}.to raise_error ArgumentError }
    end
  end

  describe '#rollback_changes' do
    let(:version) { build :video_version }
    it { expect{version.rollback_changes}.to raise_error NotImplementedError }
  end
end
