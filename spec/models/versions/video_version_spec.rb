describe Versions::VideoVersion do
  describe '#action' do
    let(:version) do
      build :video_version,
        item_diff: {
          action: Versions::VideoVersion::Actions[:upload]
        }
    end
    it { expect(version.action).to eq Versions::VideoVersion::Actions[:upload] }
  end

  describe '#video' do
    let(:video) { create :video }

    let(:version) { build :video_version, item_diff: { videos: [video.id] } }
    it { expect(version.video).to eq video }
  end

  describe '#apply_changes' do
    let(:version) { build :video_version, item_diff: { action: action, videos: [video.id] } }
    subject! { version.apply_changes }

    context 'upload' do
      let(:video) { create :video, :uploaded }
      let(:action) { Versions::VideoVersion::Actions[:upload] }

      it { expect(video.reload).to be_confirmed }
    end

    context 'delete' do
      let(:video) { create :video, :confirmed }
      let(:action) { Versions::VideoVersion::Actions[:delete] }

      it { expect(video.reload).to be_deleted }
    end
  end

  describe '#reject_changes' do
    let(:version) { build :video_version, item_diff: { action: action, videos: [video.id] } }
    subject! { version.reject_changes }

    context 'upload' do
      let(:video) { create :video, :uploaded }
      let(:action) { Versions::VideoVersion::Actions[:upload] }

      it { expect(video.reload).to be_deleted }
    end

    context 'delete' do
      let(:video) { create :video, :confirmed }
      let(:action) { Versions::VideoVersion::Actions[:delete] }

      it { expect(video.reload).to be_confirmed }
    end
  end

  describe '#rollback_changes' do
    let(:version) do
      build :video_version, :accepted,
        item_diff: { action: action, videos: [video.id] }
    end
    subject! { version.rollback_changes }

    context 'upload' do
      let(:video) { create :video, :confirmed }
      let(:action) { Versions::VideoVersion::Actions[:upload] }

      it { expect(video.reload).to be_deleted }
    end

    context 'delete' do
      let(:video) { create :video, :deleted }
      let(:action) { Versions::VideoVersion::Actions[:delete] }

      it { expect(video.reload).to be_confirmed }
    end
  end

  describe '#cleanup' do
    let(:video) { create :video }
    let(:version) do
      build :video_version,
        item_diff: {
          action: action,
          videos: [video.id]
        }
    end

    subject! { version.cleanup }

    context 'upload' do
      let(:action) { Versions::VideoVersion::Actions[:upload] }
      it { expect { video.reload }.to raise_error ActiveRecord::RecordNotFound }
    end

    context 'delete' do
      let(:action) { Versions::VideoVersion::Actions[:delete] }
      it { expect(video.reload).to be_persisted }
    end
  end
end
