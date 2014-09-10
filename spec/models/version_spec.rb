require 'spec_helper'

describe Version do
  describe :validations do
    it { should validate_presence_of :item_type }
    it { should validate_presence_of :item_id }
    it { should validate_presence_of :item_diff }
  end

  describe :state_machine do
    let(:anime) { create :anime }
    let(:video) { create :anime_video, anime: anime, episode: 2 }
    let(:diff_hash) { {episode: [1,2]} }
    let(:version) { create :version_anime_video, item_id: video.id, item_diff: diff_hash.to_s, state: state }
    subject { version }

    describe '#accept' do
      before { version.accept }

      describe 'from accepted_pending' do
        let(:state) { :accepted_pending }
        it { should be_accepted }
        specify { video.reload.episode.should eq 2 }
      end

      describe 'from pending' do
        let(:state) { :pending }
        it { should be_accepted }
        specify { video.reload.episode.should eq 2 }
      end
    end

    describe '#reject' do
      before { version.reject }

      describe 'from accepted_pending' do
        let(:state) { :accepted_pending }
        subject { version }
        it { should be_rejected }
        specify { video.reload.episode.should eq 1 }
      end

      describe 'from pending' do
        let(:state) { :pending }
        it { should be_rejected }
        specify { video.reload.episode.should eq 1 }
      end
    end
  end
end
