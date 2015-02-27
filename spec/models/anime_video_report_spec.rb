require 'cancan/matchers'

describe AnimeVideoReport do
  describe 'relations' do
    it { should belong_to :anime_video }
    it { should belong_to :user }
    it { should belong_to :approver }
  end

  describe 'validations' do
    it { should validate_presence_of :user }
    it { should validate_presence_of :anime_video }
    it { should validate_presence_of :kind }

    describe 'accepted' do
      subject { build :anime_video_report, state: 'accepted' }
      it { should validate_presence_of :approver }
    end

    describe 'rejected' do
      subject { build :anime_video_report, state: 'rejected' }
      it { should validate_presence_of :approver }
    end
  end

  describe 'scopes' do
    describe 'pending' do
      subject { AnimeVideoReport.pending }

      context 'empty' do
        it { should be_empty }
      end

      context 'with_data' do
        let(:approver) { build_stubbed :user }
        let!(:pending_report) { create :anime_video_report, state: 'pending' }
        before { create :anime_video_report, state: 'accepted', approver: approver }

        its(:count) { should eq 1 }
        its(:first) { should eq pending_report }
      end

      context 'order' do
        let!(:report_new) { create :anime_video_report, state: 'pending', created_at: Date.today - 1.day }
        let!(:report_old) { create :anime_video_report, state: 'pending', created_at: Date.today - 100.day }
        it { expect(subject.first).to eq report_old }
      end
    end

    describe 'processed' do
      subject { AnimeVideoReport.processed }

      context 'empty' do
        it { should be_empty }
      end

      context 'with_data' do
        let(:approver) { build_stubbed :user }
        let!(:pending_report) { create :anime_video_report, state: 'pending' }
        let!(:accepted_report) { create :anime_video_report, state: 'accepted' }
        let!(:rejected_report) { create :anime_video_report, state: 'rejected' }

        its(:count) { should eq 2 }
        specify { expect(subject.include?(pending_report)).to be_falsy }
      end
    end
  end

  describe 'callbacks' do
    describe 'after_create' do
      describe '#auto_check' do
        before { allow(AnimeOnline::ReportWorker).to receive(:delay_for).and_return task_double }

        let!(:report) { create :anime_video_report, :with_video, :with_user }
        let(:task_double) { double perform_async: nil }

        it { expect(AnimeOnline::ReportWorker).to have_received(:delay_for).with(10.seconds) }
        it { expect(task_double).to have_received(:perform_async).with report.id }
      end

      describe '#auto_accept' do
        subject { create :anime_video_report, :with_video, user: user }

        context 'user' do
          let(:user) { create :user, :user }
          it { should be_pending }
        end

        context 'video moderator' do
          let(:user) { create :user, :video_moderator }
          it { should be_accepted }
        end
      end
    end
  end

  describe 'doubles' do
    let!(:report) { create :anime_video_report, anime_video: anime_video, state: state_1 }
    let(:state_1) { 'rejected' }
    let(:anime_video) { create :anime_video }
    subject { report.doubles }

    context 'no_doubles' do
      it { should be_zero }

      context 'one_user_not_filter' do
        let(:user) { create :user, :user }
        let(:report) { create :anime_video_report, anime_video: anime_video, user: user, state: state_1 }
        before { create :anime_video_report, anime_video: anime_video, user: user, state: state_1 }

        it { should eq 1 }
      end
    end

    context 'with_double' do
      before { create :anime_video_report, anime_video: anime_video, state: state_1 }

      context 'without_state' do
        it { should eq 1 }
      end

      context 'with_state' do
        subject { report.doubles state_2 }

        context 'other_state' do
          let(:state_2) { 'accepted' }
          it { should eq 0 }
        end

        context 'eq_state' do
          let(:state_2) { state_1 }
          it { should eq 1 }
        end
      end
    end
  end

  describe 'state_machine' do
    let(:approver) { build_stubbed :user }
    let(:anime_video) { create :anime_video, state: anime_video_state }
    let(:anime_video_state) { 'working' }
    let(:report_kind) { 'broken' }
    let(:other_report) { }
    subject(:report) { create :anime_video_report, anime_video: anime_video, kind: report_kind, state: 'pending' }

    describe '#accept' do
      before { other_report }
      before { report.accept approver }
      its(:approver) { should eq approver }

      context 'video was working' do
        let(:anime_video_state) { 'working' }
        it { is_expected.to be_accepted }
        it { expect(subject.anime_video).to be_broken }
      end

      context 'video was uploaded' do
        let(:anime_video_state) { 'uploaded' }
        it { is_expected.to be_accepted }
        it { expect(subject.anime_video).to be_broken }

        describe 'cancel other uploaded report' do
          let(:other_report) { create(:anime_video_report, anime_video: anime_video, kind: 'uploaded', state: 'pending') }
          it { expect(other_report.reload.state).to eq 'rejected' }
        end
      end

      context 'Fix : https://github.com/morr/shikimori/issues/414' do
        let(:anime_video) { create(:anime_video, kind: 'unknown', state: 'working') }
        subject(:report) { create(:anime_video_report, anime_video: anime_video, kind: 'broken', state: 'pending') }
        it { is_expected.to be_accepted }
        it { expect(subject.anime_video).to be_broken }
      end
    end

    describe '#reject' do
      before { report.reject approver }
      its(:approver) { should eq approver }

      describe 'anime_video_state' do
        subject { report.anime_video }

        context 'broken' do
          it { should be_working }
        end

        context 'uploaded' do
          let(:report_kind) { 'uploaded' }
          let(:anime_video_state) { 'uploaded' }
          it { should be_rejected }
        end
      end
    end

    describe '#cancel' do
      let(:report) { create :anime_video_report, anime_video: anime_video, kind: report_kind, approver: approver, state: 'accepted' }
      let(:canceler) { build_stubbed :user }
      let(:anime_video_state) { 'broken' }
      before { report.cancel canceler }

      its(:approver) { should eq canceler }
      it { should be_pending }

      describe 'anime_video_state' do
        subject { report.anime_video }
        it { should be_working }
      end
    end


    describe 'repeat event for doubles' do
      let(:report_user_1) { create :user, :user }
      let(:report_user_2) { create :user, :user }
      let(:report_user_3) { create :user, :user }
      let!(:report_1) { create :anime_video_report, anime_video: anime_video, kind: report_kind, user: report_user_1 }
      let!(:report_2) { create :anime_video_report, anime_video: anime_video, kind: report_kind, user: report_user_2 }
      let!(:report_3) { create :anime_video_report, anime_video: anime_video, kind: report_kind, user: report_user_3 }
      let!(:report_other_kind) { create :anime_video_report, anime_video: anime_video, kind: report_kind_other, user: report_user_2 }

      context 'from_working_to_other' do
        let(:anime_video_state) { 'working' }

        context 'broken_report' do
          let(:report_kind) { 'broken' }
          let(:report_kind_other) { 'wrong' }

          describe '#accept' do
            before { report_1.accept approver }

            specify { expect(report_2.reload).to be_accepted }
            specify { expect(report_2.reload.approver_id).to eq approver.id }
            specify { expect(report_3.reload).to be_accepted }
            specify { expect(report_3.reload.approver_id).to eq approver.id }
            specify { expect(report_other_kind.reload).to be_pending }
            specify { expect(report_other_kind.reload.approver_id).to be_nil }
          end

          describe '#reject' do
            before { report_1.reject approver }

            specify { expect(report_2.reload).to be_rejected }
            specify { expect(report_2.reload.approver_id).to eq approver.id }
            specify { expect(report_3.reload).to be_rejected }
            specify { expect(report_3.reload.approver_id).to eq approver.id }
            specify { expect(report_other_kind.reload).to be_pending }
            specify { expect(report_other_kind.reload.approver_id).to be_nil }
          end
        end

        context 'wrong_report' do
          let(:report_kind) { 'wrong' }
          let(:report_kind_other) { 'broken' }

          describe '#accept' do
            before { report_1.accept approver }

            specify { expect(report_2.reload).to be_accepted }
            specify { expect(report_2.reload.approver_id).to eq approver.id }
            specify { expect(report_3.reload).to be_accepted }
            specify { expect(report_3.reload.approver_id).to eq approver.id }
            specify { expect(report_other_kind.reload).to be_pending }
            specify { expect(report_other_kind.reload.approver_id).to be_nil }
          end

          describe '#reject' do
            before { report_1.reject approver }

            specify { expect(report_2.reload).to be_rejected }
            specify { expect(report_2.reload.approver_id).to eq approver.id }
            specify { expect(report_3.reload).to be_rejected }
            specify { expect(report_3.reload.approver_id).to eq approver.id }
            specify { expect(report_other_kind.reload).to be_pending }
            specify { expect(report_other_kind.reload.approver_id).to be_nil }
          end
        end
      end

      context 'from_other_to_working' do
        context 'broken_report' do
          let(:report_kind) { 'broken' }
          let(:report_kind_other) { 'wrong' }
          before do
            report_1.accept approver
            report_1.cancel approver
          end

          specify { expect(report_2.reload).to be_pending }
          specify { expect(report_2.reload.approver_id).to eq approver.id }
          specify { expect(report_3.reload).to be_pending }
          specify { expect(report_3.reload.approver_id).to eq approver.id }
          specify { expect(report_other_kind.reload).to be_pending }
          specify { expect(report_other_kind.reload.approver_id).to be_nil }
        end
      end
    end
  end

  describe 'permissions' do
    let(:report) { build_stubbed :anime_video_report, user_id: user_id, kind: kind }
    let(:user_id) { user.id }
    let(:kind) { :broken }
    subject { Ability.new user }

    context 'moderator' do
      let(:user) { build_stubbed :user, :video_moderator }
      it { should be_able_to :manage, report }
    end

    context 'user' do
      let(:user) { build_stubbed :user, :user }
      it { should_not be_able_to :manage, report }

      context 'uploaded' do
        let(:kind) { :uploaded }
        it { should_not be_able_to :create, report }
      end

      context 'broken' do
        let(:kind) { :broken }
        it { should be_able_to :create, report }
      end

      context 'wrong' do
        let(:kind) { :wrong }
        it { should be_able_to :create, report }
      end
    end

    context 'guest' do
      let(:user) { nil }
      let(:user_id) { User::GuestID }
      it { should_not be_able_to :manage, report }
      it { should be_able_to :create, report }
    end
  end
end
