require 'spec_helper'

describe AnimeVideoReport do
  describe :relations do
    it { should belong_to :anime_video }
    it { should belong_to :user }
    it { should belong_to :approver }
  end

  describe :validations do
    it { should validate_presence_of :user }
    it { should validate_presence_of :anime_video }
    it { should validate_presence_of :kind }

    describe :accepted do
      subject { build :anime_video_report, state: 'accepted' }
      it { should validate_presence_of :approver }
    end

    describe :rejected do
      subject { build :anime_video_report, state: 'rejected' }
      it { should validate_presence_of :approver }
    end
  end

  describe :scopes do
    describe :pending do
      subject { AnimeVideoReport.pending }

      context :empty do
        it { should be_empty }
      end

      context :with_data do
        let(:approver) { build_stubbed :user }
        let!(:pending_report) { create :anime_video_report, state: 'pending' }
        before { create :anime_video_report, state: 'accepted', approver: approver }

        its(:count) { should eq 1 }
        its(:first) { should eq pending_report }
      end
    end
  end

  describe :state_machine do
    let(:approver) { build_stubbed :user }
    let(:anime_video) { create :anime_video, state: 'working' }
    let(:report_kind) { 'broken' }
    subject(:report) { create :anime_video_report, anime_video: anime_video, kind: report_kind }

    describe :accept do
      before { report.accept approver }
      its(:approver) { should eq approver }

      describe :anime_video_state do
        subject { report.anime_video.state }
        it { should eq report_kind }
      end
    end

    describe :reject do
      before { report.reject approver }
      its(:approver) { should eq approver }

      describe :anime_video_state do
        subject { report.anime_video.state }
        it { should eq 'working' }
      end
    end
  end
end
