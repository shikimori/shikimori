require 'cancan/matchers'

describe Version do
  describe 'relations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to :moderator }
    it { is_expected.to belong_to :item }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :item }
    it { is_expected.to validate_presence_of :item_diff }
    #it { is_expected.to validate_length_of(:reason).is_at_most Version::MAXIMUM_REASON_SIZE }
  end

  describe 'state_machine' do
    let(:anime) { build_stubbed :anime }
    let(:video) { create :anime_video, anime: anime, episode: 2 }
    let(:moderator) { build_stubbed :user }
    subject(:version) { create :version_anime_video, item_id: video.id, item_diff: { episode: [1,2] }, state: state }

    before { allow(version).to receive(:apply_changes).and_return true }
    before { allow(version).to receive(:rollback_changes).and_return true }
    before { allow(version).to receive :notify_acceptance }
    before { allow(version).to receive :notify_rejection }

    describe '#accept' do
      before { version.accept! moderator }

      describe 'from pending' do
        let(:state) { :pending }

        it do
          expect(version).to be_accepted
          expect(version.moderator).to eq moderator
          expect(version).to have_received :apply_changes
          expect(version).to_not have_received :rollback_changes
          expect(version).to have_received :notify_acceptance
          expect(version).to_not have_received :notify_rejection
        end
      end
    end

    describe '#take' do
      before { version.take! moderator }

      describe 'from pending' do
        let(:state) { :pending }

        it do
          expect(version).to be_taken
          expect(version.moderator).to eq moderator
          expect(version).to have_received :apply_changes
          expect(version).to_not have_received :rollback_changes
          expect(version).to have_received :notify_acceptance
          expect(version).to_not have_received :notify_rejection
        end
      end
    end

    describe '#reject' do
      before { version.reject! moderator, 'reason' }

      describe 'from auto_accepted' do
        let(:state) { :auto_accepted }

        it do
          expect(version).to be_rejected
          expect(version).to_not have_received :apply_changes
          expect(version).to have_received :rollback_changes
          expect(version).to_not have_received :notify_acceptance
          expect(version).to have_received :notify_rejection
        end
      end

      describe 'from pending' do
        let(:state) { :pending }

        it do
          expect(version).to be_rejected
          expect(version.moderator).to eq moderator
          expect(version).to_not have_received :apply_changes
          expect(version).to_not have_received :rollback_changes
          expect(version).to_not have_received :notify_acceptance
          expect(version).to have_received(:notify_rejection).with 'reason'
        end
      end
    end

    describe '#accept_taken' do
      let(:state) { :taken }
      it { expect(version).to_not be_can_accept_taken }
    end

    describe '#take_accepted' do
      let(:state) { :accepted }
      it { expect(version).to_not be_can_take_accepted }
    end
  end

  describe 'class methods' do
    describe '.pending_count & .has_changes?' do
      let!(:version_1) { create :version, state: 'accepted' }

      context 'has pending versions' do
        let!(:version_2) { create :version, state: 'pending' }

        it { expect(Version.pending_count).to eq 1 }
        it { expect(Version.has_changes?).to eq true }
      end

      context 'no pending versions' do
        it { expect(Version.pending_count).to be_zero }
        it { expect(Version.has_changes?).to eq false }
      end
    end
  end

  describe 'instance methods' do
    let(:anime) { create :anime, episodes: 10 }
    let(:version) { create :version, item: anime, item_diff: { episodes: [1,2] } }

    describe '#reason=' do
      let(:version) { build :version, reason: 'a' * 3000 }
      it { expect(version.reason).to have(Version::MAXIMUM_REASON_SIZE).items }
    end

    describe '#apply_changes' do
      before { version.apply_changes }

      it do
        expect(anime.reload.episodes).to eq 2
        expect(anime.desynced).to include 'episodes'
        expect(version.reload.item_diff['episodes'].first).to eq 10
      end
    end

    describe '#rollback_changes' do
      before { version.rollback_changes }
      it { expect(anime.reload.episodes).to eq 1 }
    end

    describe '#notify_acceptance' do
      let(:version) { create :version, item: anime, item_diff: { episodes: [1,2] },
        user: user, moderator: moderator }
      let(:user) { create :user }

      context 'user == moderator' do
        let(:moderator) { user }
        it { expect{version.notify_acceptance}.to_not change(user.messages, :count) }
      end

      context 'user != moderator' do
        let(:moderator) { create :user }
        it { expect{version.notify_acceptance}.to change(user.messages, :count).by 1 }
      end
    end

    describe '#notify_rejection' do
      let(:version) { create :version, item: anime, item_diff: { episodes: [1,2] },
        user: user, moderator: moderator }
      let(:user) { create :user }

      context 'user == moderator' do
        let(:moderator) { user }
        it { expect{version.notify_rejection 'z'}.to_not change(user.messages, :count) }
      end

      context 'user != moderator' do
        let(:moderator) { create :user }
        it { expect{version.notify_rejection 'z'}.to change(user.messages, :count).by 1 }
      end
    end
  end

  describe 'permissions' do
    let(:version) { build_stubbed :version }

    context 'user_chagnes_moderator' do
      subject { Ability.new build_stubbed(:user, :versions_moderator) }
      it { is_expected.to be_able_to :manage, version }
    end

    context 'guest' do
      subject { Ability.new nil }

      describe 'own version' do
        let(:version) { build_stubbed :version, user_id: User::GUEST_ID,
          item_diff: item_diff }
        let(:item_diff) {{ russian: ['a','b'] }}

        describe 'common change'do
          it { is_expected.to be_able_to :create, version }
        end

        describe 'significant change' do
          let(:item_diff) {{ name: ['a','b'] }}
          it { is_expected.to_not be_able_to :create, version }
        end

        it { is_expected.to be_able_to :show, version }
        it { is_expected.to be_able_to :tooltip, version }
        it { is_expected.to_not be_able_to :destroy, version }
        it { is_expected.to_not be_able_to :manage, version }
      end

      describe 'user version' do
        it { is_expected.to be_able_to :show, version }
        it { is_expected.to be_able_to :tooltip, version }
        it { is_expected.to_not be_able_to :create, version }
        it { is_expected.to_not be_able_to :destroy, version }
        it { is_expected.to_not be_able_to :manage, version }
      end
    end

    context 'user' do
      let(:user) { build_stubbed :user, :user }
      subject { Ability.new user }

      describe 'own version' do
        let(:version) { build_stubbed :version, user: user, item_diff: item_diff }
        let(:item_diff) {{ russian: ['a','b'] }}

        describe 'common change'do
          it { is_expected.to be_able_to :create, version }
        end

        describe 'significant change' do
          let(:item_diff) {{ name: ['a','b'] }}
          it { is_expected.to_not be_able_to :create, version }
        end

        it { is_expected.to be_able_to :show, version }
        it { is_expected.to be_able_to :tooltip, version }
        it { is_expected.to be_able_to :destroy, version }
        it { is_expected.to_not be_able_to :manage, version }
      end

      describe 'user version' do
        it { is_expected.to be_able_to :show, version }
        it { is_expected.to be_able_to :tooltip, version }
        it { is_expected.to_not be_able_to :create, version }
        it { is_expected.to_not be_able_to :destroy, version }
        it { is_expected.to_not be_able_to :manage, version }
      end
    end
  end
end
