describe Ban do
  describe 'relations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to :moderator }
    it { is_expected.to belong_to :comment }
    it { is_expected.to belong_to :abuse_request }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :user }
    it { is_expected.to validate_presence_of :moderator }
    it { is_expected.to validate_presence_of :duration }
    it { is_expected.to validate_presence_of :reason }

    #it { is_expected.to validate_presence_of :comment }
    #it { is_expected.to validate_presence_of :abuse_request }
  end

  let(:duration) { 60 }
  let(:reason) { 'test' }
  let(:user) { create :user }
  let(:moderator) { user }
  let(:comment) { create :comment, user: user }
  let(:params) {{ user: user, comment: comment, moderator: moderator, duration: duration, reason: reason }}

  describe 'callbacks' do
    describe '#set_user' do
      let(:ban) { build :ban, params }
      after { ban.valid? }
      it { expect(ban).to receive :set_user }
    end

    describe '#ban_user' do
      let(:ban) { build :ban, params }
      after { ban.save }
      it { expect(ban).to receive :ban_user }
    end

    describe '#mention_in_comment' do
      let(:ban) { build :ban, params }
      after { ban.save }
      it { expect(ban).to receive :mention_in_comment }
    end

    describe '#notify_user' do
      let(:ban) { build :ban, params }
      after { ban.save }
      it { expect(ban).to receive :notify_user }
    end

    describe '#accept_abuse_request' do
      let(:ban) { build :ban, params }
      after { ban.save }
      it { expect(ban).to receive :accept_abuse_request }
    end
  end

  describe 'instance methods' do
    describe '#warning?' do
      subject { ban.warning? }
      let(:ban) { create :ban, :no_callbacks, params }

      describe true do
        let(:duration) { 0 }
        it { is_expected.to be_truthy }
      end

      describe false do
        let(:duration) { 1 }
        it { is_expected.to be_falsy }
      end
    end

    describe '#message' do
      subject { ban.message }
      let(:ban) { build_stubbed :ban, params }

      context 'warning' do
        let(:duration) { 0 }
        it { is_expected.to eq "предупреждение. #{reason}." }
      end

      context 'ban' do
        let(:duration) { '3h 5m' }
        it { is_expected.to eq "бан на 3 часа 5 минут. #{reason}." }
      end
    end

    describe '#ban_user' do
      before { Timecop.freeze }
      after { Timecop.return }

      subject { user.read_only_at }
      let!(:ban) { create :ban, params.merge(created_at: Time.zone.now) }

      context 'user_witout_prior_ban' do
        it { is_expected.to eq ban.duration.minutes.from_now }
      end

      context 'user_with_prior_ban' do
        let(:user) { create :user, read_only_at: 10.minutes.from_now }
        it { is_expected.to eq 10.minutes.from_now + ban.duration.minutes }
      end
    end

    describe '#mention_in_comment' do
      subject { comment.body }
      let(:comment) { create :comment, user: user, body: "test\n" }

       context 'no_prior_ban' do
        let!(:ban) { create :ban, params }
        it { is_expected.to eq "test\n\n[ban=#{ban.id}]" }
      end

       context 'with_prior_ban' do
        let!(:prior_ban) { create :ban, params }
        let!(:ban) { create :ban, params }
        it { is_expected.to eq "test\n\n[ban=#{prior_ban.id}][ban=#{ban.id}]" }
      end
    end

    describe '#notify_user' do
      let(:moderator) { create :user }
      subject(:ban) { create :ban, params }
      let(:messages) { Message.where from_id: moderator.id, to_id: user.id, linked_type: Ban.name, kind: MessageType::Banned }
      it { expect{ban}.to change(messages, :count).by 1 }
    end

    describe '#suggest_duration' do
      subject { ban.suggest_duration }
      let(:ban) { build_stubbed :ban, params }
      before { allow_any_instance_of(UsersQuery).to receive(:bans_count).and_return bans_count }

      context '0 bans' do
        let(:bans_count) { 0 }
        it { is_expected.to eq '0m' }
      end

      context '1 ban' do
        let(:bans_count) { 1 }
        it { is_expected.to eq '15m' }
      end

      context '2 bans' do
        let(:bans_count) { 2 }
        it { is_expected.to eq '2h' }
      end

      context '5 bans' do
        let(:bans_count) { 5 }
        it { is_expected.to eq '1d 7h 15m' }
      end

      context '8 bans' do
        let(:bans_count) { 8 }
        it { is_expected.to eq '2d 16h' }
      end

      context '12 bans' do
        let(:bans_count) { 12 }
        it { is_expected.to eq '6d' }
      end

      context '15 bans' do
        let(:bans_count) { 15 }
        it { is_expected.to eq '1w 2d 9h' }
      end

      context '16 bans' do
        let(:bans_count) { 16 }
        it { is_expected.to eq '1w 3d 12h' }
      end
    end

    describe '#accept_abuse_request' do
      let(:abuse_request) { create :abuse_request, user: user, comment: comment }
      let(:ban) { create :ban, params.merge(abuse_request: abuse_request) }
      subject { ban.abuse_request }
      it { is_expected.to be_accepted }
      its(:approver_id) { is_expected.to eq ban.moderator_id }
    end
  end
end
