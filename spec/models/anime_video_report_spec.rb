describe AnimeVideoReport do
  describe 'relations' do
    it { is_expected.to belong_to :anime_video }
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to :approver }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :user }
    it { is_expected.to validate_presence_of :anime_video }
    it { is_expected.to validate_presence_of :kind }

    describe 'accepted' do
      subject { build :anime_video_report, state: 'accepted' }
      it { is_expected.to validate_presence_of :approver }
    end

    describe 'rejected' do
      subject { build :anime_video_report, state: 'rejected' }
      it { is_expected.to validate_presence_of :approver }
    end
  end

  describe 'scopes' do
    describe 'pending' do
      subject { AnimeVideoReport.pending }

      context 'empty' do
        it { is_expected.to be_empty }
      end

      context 'with_data' do
        let(:approver) { build_stubbed :user }
        let!(:pending_report) { create :anime_video_report, state: 'pending' }
        before { create :anime_video_report, state: 'accepted', approver: approver }

        its(:count) { is_expected.to eq 1 }
        its(:first) { is_expected.to eq pending_report }
      end

      context 'order' do
        let!(:report_new) { create :anime_video_report, state: 'pending', created_at: Time.zone.today - 1.day }
        let!(:report_old) { create :anime_video_report, state: 'pending', created_at: Time.zone.today - 100.day }
        it { expect(subject.first).to eq report_old }
      end
    end

    describe 'processed' do
      subject { AnimeVideoReport.processed }

      context 'empty' do
        it { is_expected.to be_empty }
      end

      context 'with_data' do
        let(:approver) { build_stubbed :user }
        let!(:pending_report) { create :anime_video_report, state: 'pending' }
        let!(:accepted_report) { create :anime_video_report, state: 'accepted' }
        let!(:rejected_report) { create :anime_video_report, state: 'rejected' }

        its(:count) { is_expected.to eq 2 }
        specify { expect(subject.include?(pending_report)).to eq false }
      end
    end
  end

  describe 'callbacks' do
    describe 'after_create' do
      describe '#auto_check' do
        before { allow(AnimeOnline::ReportWorker).to receive(:perform_in).and_return task_double }

        let!(:report) { create :anime_video_report, :with_video, :with_user }
        let(:task_double) { double perform_async: nil }

        it { expect(AnimeOnline::ReportWorker).to have_received(:perform_in).with 10.seconds, report.id }
      end

      describe '#auto_accept' do
        subject { create :anime_video_report, :with_video, kind, user: user }
        let(:kind) { :broken }

        context 'user' do
          it { is_expected.to be_pending }
        end

        context 'video moderator' do
          let(:user) { create :user, :video_moderator }
          it { is_expected.to be_accepted }

          context 'kind=other' do
            let(:kind) { :other }
            let(:user) { create :user, :video_moderator }
            it { is_expected.to be_pending }
          end
        end
      end
    end
  end

  describe '#doubles' do
    let!(:report) { create :anime_video_report, anime_video: anime_video, state: state_1 }
    let(:state_1) { 'rejected' }
    let(:anime_video) { create :anime_video }
    subject { report.doubles }

    context 'no_doubles' do
      it { is_expected.to be_zero }

      context 'one_user_not_filter' do
        let(:report) { create :anime_video_report, anime_video: anime_video, user: user, state: state_1 }
        before { create :anime_video_report, anime_video: anime_video, user: user, state: state_1 }

        it { is_expected.to eq 1 }
      end
    end

    context 'with_double' do
      before { create :anime_video_report, anime_video: anime_video, state: state_1, user: user }
      let(:user) { build_stubbed :user }

      context 'without_state' do
        it { is_expected.to eq 1 }
      end

      context 'with_state' do
        subject { report.doubles state_2 }

        context 'other_state' do
          let(:state_2) { 'accepted' }
          it { is_expected.to eq 0 }
        end

        context 'eq_state' do
          let(:state_2) { state_1 }

          context 'guest report' do
            let(:user) { build_stubbed :user, id: User::GUEST_ID }
            it { is_expected.to eq 0 }
          end

          context 'user report' do
            it { is_expected.to eq 1 }
          end
        end
      end
    end
  end

  describe 'state_machine' do
    let(:approver) { build_stubbed :user }
    let(:anime_video) { create :anime_video, state: anime_video_state }
    let(:anime_video_state) { 'working' }
    let(:report_kind) { 'broken' }
    let!(:initial_report) {}
    subject(:report) { create :anime_video_report, :pending, anime_video: anime_video, kind: report_kind }

    describe '#accept' do
      before { report.accept! approver }

      its(:approver) { is_expected.to eq approver }

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
          let!(:initial_report) { create :anime_video_report, :uploaded, :pending, anime_video: anime_video }
          it { expect(initial_report.reload).to be_rejected }
        end
      end

      context 'fix : https://github.com/morr/shikimori/issues/414' do
        let(:anime_video) { create :anime_video, kind: 'unknown', state: 'working' }
        subject(:report) do
          create :anime_video_report,
            anime_video: anime_video,
            kind: 'broken',
            state: 'pending'
        end

        it { is_expected.to be_accepted }
        it { expect(report.anime_video).to be_broken }
      end

      context 'accept with broken url' do
        let(:anime_video) do
          v = build :anime_video, url: '//youtube.ru/foo', state: 'working'
          v.save(validate: false)
          v
        end
        it { is_expected.to be_accepted }
      end

      context 'accept kind=other report' do
        let(:anime_video) { create :anime_video, kind: 'unknown', state: 'working' }
        subject(:report) do
          create :anime_video_report,
            anime_video: anime_video,
            kind: 'other',
            state: 'pending'
        end

        it { is_expected.to be_accepted }
        it { expect(report.anime_video).to be_working }
      end

      context 'accept already broken video' do
        let(:anime_video) { create :anime_video, state: 'broken' }
        it { is_expected.to be_accepted }
        it { expect(subject.anime_video).to be_broken }
      end

      context 'accept already wrong video' do
        let(:anime_video) { create :anime_video, state: 'wrong' }
        let(:report_kind) { 'wrong' }
        it { is_expected.to be_accepted }
        it { expect(subject.anime_video).to be_wrong }
      end
    end

    # Возможно при множественной модерации одной жалобы модераторами, либо если успел вперд sidekiq.
    context 'Accept already accepted - https://github.com/morr/shikimori/issues/463' do
      let(:anime) { create :anime }
      let(:anime_video) { create :anime_video, :uploaded, anime: anime }
      let(:user) { create :user, id: 43_311 }
      let(:approver_1) { create :user }
      let(:approver_2) { create :user }
      let(:report) { create :anime_video_report, :pending, :uploaded, anime_video: anime_video, user: user }
      before do
        report.reload.accept! approver_1
        report.reload.accept! approver_2
      end
      it { expect(report).to be_accepted }
      it { expect(report.approver).to eq approver_1 }
    end

    context 'Fix : https://github.com/morr/shikimori/issues/427' do
      let(:url) { attributes_for(:anime_video)[:url] }
      let!(:other_video) { create :anime_video, :working, kind: 'fandub', url: url }
      let!(:anime_video) { create :anime_video, :working, kind: 'fandub', url: url + '1' }
      let!(:report) { create :anime_video_report, :pending, anime_video: anime_video, kind: 'broken', approver_id: approver.id }
      before { report.accept! approver }

      it { expect(report).to be_accepted }
      it { expect(anime_video).to be_broken }
    end

    describe '#reject' do
      before { report.reject approver }
      its(:approver) { is_expected.to eq approver }

      describe 'anime_video_state' do
        subject { report.anime_video }

        context 'broken' do
          it { is_expected.to be_working }
        end

        context 'uploaded' do
          let(:report_kind) { 'uploaded' }
          let(:anime_video_state) { 'uploaded' }
          it { is_expected.to be_rejected }
        end
      end
    end

    describe '#cancel' do
      let(:report) { create :anime_video_report, anime_video: anime_video, kind: report_kind, approver: approver, state: 'accepted' }
      let(:canceler) { build_stubbed :user }
      let(:anime_video_state) { 'broken' }
      before { report.cancel canceler }

      its(:approver) { is_expected.to eq canceler }
      it { is_expected.to be_pending }

      describe 'anime_video_state' do
        subject { report.anime_video }
        it { is_expected.to be_working }
      end
    end

    describe 'repeat event for doubles' do
      let(:report_user_1) { create :user, :user }
      let(:report_user_2) { create :user, :user }
      let(:report_user_3) { create :user, :user }
      let!(:report_1) { create :anime_video_report, anime_video: anime_video, kind: report_kind, user: report_user_1 }
      let!(:report_2) { create :anime_video_report, anime_video: anime_video, kind: report_kind, user: report_user_2 }
      let!(:report_3) { create :anime_video_report, anime_video: anime_video, kind: report_kind, user: report_user_3 }
      let!(:report_other) { create :anime_video_report, anime_video: anime_video, kind: report_other_kind, user: report_user_2 }

      context 'from working to other' do
        let(:anime_video_state) { 'working' }

        context 'broken report' do
          let(:report_kind) { 'broken' }
          let(:report_other_kind) { 'wrong' }

          describe '#accept' do
            before { report_1.accept approver }

            it do
              expect(report_2.reload).to be_accepted
              expect(report_2.approver_id).to eq approver.id
              expect(report_3.reload).to be_accepted
              expect(report_3.approver_id).to eq approver.id
              expect(report_other.reload).to be_accepted
              expect(report_other.approver_id).to_not eq approver.id
            end
          end

          describe '#reject' do
            before { report_1.reject approver }

            it do
              expect(report_2.reload).to be_rejected
              expect(report_2.approver_id).to eq approver.id
              expect(report_3.reload).to be_rejected
              expect(report_3.approver_id).to eq approver.id
              expect(report_other.reload).to be_pending
              expect(report_other.approver_id).to be_nil
            end
          end
        end

        context 'wrong report' do
          let(:report_kind) { 'wrong' }
          let(:report_other_kind) { 'broken' }

          describe '#accept' do
            before { report_1.accept approver }

            it do
              expect(report_2.reload).to be_accepted
              expect(report_2.approver_id).to eq approver.id
              expect(report_3.reload).to be_accepted
              expect(report_3.approver_id).to eq approver.id
              expect(report_other.reload).to be_accepted
              expect(report_other.approver_id).to_not eq approver.id
            end
          end

          describe '#reject' do
            before { report_1.reject approver }

            it do
              expect(report_2.reload).to be_rejected
              expect(report_2.approver_id).to eq approver.id
              expect(report_3.reload).to be_rejected
              expect(report_3.approver_id).to eq approver.id
              expect(report_other.reload).to be_pending
              expect(report_other.approver_id).to be_nil
            end
          end
        end
      end

      context 'from other to working' do
        context 'broken report' do
          let(:report_kind) { 'broken' }
          let(:report_other_kind) { 'wrong' }
          before do
            report_1.accept! approver
            report_1.cancel! approver
          end

          it do
            expect(report_2.reload).to be_accepted
            expect(report_2.approver_id).to eq approver.id
            expect(report_3.reload).to be_accepted
            expect(report_3.approver_id).to eq approver.id
            expect(report_other.reload).to be_accepted
            expect(report_other.approver_id).to_not eq approver.id
          end
        end
      end
    end
  end

  describe 'permissions' do
    let(:report) do
      build_stubbed :anime_video_report, state,
        user_id: user_id,
        kind: kind
    end
    let(:state) { :pending }
    let(:user_id) { user.id }
    let(:kind) { :broken }

    subject { Ability.new user }

    context 'moderator' do
      let(:user) { build_stubbed :user, :video_moderator }
      it { is_expected.to be_able_to :manage, report }
    end

    context 'user' do
      let(:user) { build_stubbed :user, :user }
      it { is_expected.to_not be_able_to :manage, report }

      context 'pending' do
        it { is_expected.to be_able_to :destroy, report }
      end

      context 'not pending' do
        let(:state) { %i[accepted rejected].sample }
        it { is_expected.to_not be_able_to :destroy, report }
      end

      context 'uploaded' do
        let(:kind) { :uploaded }
        it { is_expected.to_not be_able_to :create, report }
      end

      %i[wrong broken].each do |kind|
        context kind.to_s do
          let(:kind) { kind }

          context 'not banned' do
            it { is_expected.to be_able_to :create, report }
          end

          context 'banned' do
            let(:user) { build_stubbed :user, :user, :banned }
            it { is_expected.to_not be_able_to :create, report }
          end

          context 'not trusted video uploader' do
            let(:user) { build_stubbed :user, :user, :not_trusted_video_uploader }
            it { is_expected.to_not be_able_to :create, report }
          end
        end
      end
    end

    context 'guest' do
      let(:user) { nil }
      let(:user_id) { User::GUEST_ID }
      it { is_expected.to_not be_able_to :manage, report }
      it { is_expected.to be_able_to :create, report }
    end
  end
end
