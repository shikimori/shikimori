describe Version do
  describe 'relations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to(:moderator).optional }
    it { is_expected.to belong_to(:item).without_validating_presence }
    it { is_expected.to belong_to(:associated).optional }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :item_diff }
    # it { is_expected.to validate_length_of(:reason).is_at_most Version::MAXIMUM_REASON_SIZE }

    context 'new record' do
      subject { build :version }
      it { is_expected.to validate_presence_of :item }
    end

    context 'persisted' do
      subject { build_stubbed :version }
      it { is_expected.to_not validate_presence_of :item }
    end
  end

  describe 'state_machine' do
    let(:anime) { build_stubbed :anime }
    let(:video) { create :anime_video, anime: anime, episode: 2 }
    let(:moderator) { build_stubbed :user }
    subject(:version) do
      create :version_anime_video,
        item_id: video.id,
        item_diff: { episode: [1, 2] },
        state: state
    end

    before do
      allow(version).to receive(:apply_changes).and_return true
      allow(version).to receive(:rollback_changes).and_return true
      allow(version).to receive :notify_acceptance
      allow(version).to receive :notify_rejection
    end

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

  describe 'instance methods' do
    let(:anime) { create :anime, episodes: 10 }
    let(:version) { create :version, item: anime, item_diff: { episodes: [1, 2] } }

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
      let(:version) do
        create :version,
          item: anime,
          item_diff: { episodes: [1, 2] },
          user: user,
          moderator: moderator
      end

      context 'user == moderator' do
        let(:moderator) { user }
        it { expect { version.notify_acceptance }.to_not change(user.messages, :count) }
      end

      context 'user != moderator' do
        let(:moderator) { create :user }
        it { expect { version.notify_acceptance }.to change(user.messages, :count).by 1 }
      end
    end

    describe '#notify_rejection' do
      let(:version) do
        create :version,
          item: anime,
          item_diff: { episodes: [1, 2] },
          user: user,
          moderator: moderator
      end

      context 'user == moderator' do
        let(:moderator) { user }
        it { expect { version.notify_rejection 'z' }.to_not change(user.messages, :count) }
      end

      context 'user != moderator' do
        let(:moderator) { create :user }
        it { expect { version.notify_rejection 'z' } .to change(user.messages, :count).by 1 }
      end
    end

    describe '#takeable?' do
      it { expect(version).to_not be_takeable }
    end

    describe '#deleteable?' do
      it { expect(version).to be_deleteable }
    end
  end

  describe 'permissions' do
    let(:version) { build_stubbed :version }
    subject { Ability.new user }

    context 'version_moderator' do
      let(:user) { build_stubbed :user, :version_moderator }
      let(:version) { build_stubbed :version, item_diff: item_diff }
      let(:item_diff) { { english: ['a', 'b'] } }

      it { is_expected.to be_able_to :manage, version }

      context 'not manageable fields' do
        let(:item_diff) do
          {
            Abilities::VersionModerator::NOT_MANAGED_FIELDS.sample.to_sym => ['a', 'b']
          }
        end
        it { is_expected.to_not be_able_to :manage, version }
      end

      context 'role version' do
        let(:version) { build_stubbed :role_version, user: user }
        it { is_expected.to_not be_able_to :manage, version }
      end
    end

    context 'guest' do
      subject { Ability.new nil }

      describe 'own version' do
        let(:version) do
          build_stubbed :version,
            user_id: User::GUEST_ID,
            item_diff: {
              russian: ['a', 'b']
            }
        end

        it { is_expected.to be_able_to :show, version }
        it { is_expected.to be_able_to :tooltip, version }
        it { is_expected.to_not be_able_to :create, version }
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
      let(:user) { build_stubbed :user, :week_registered }

      describe 'own version' do
        let(:version) { build_stubbed :version, user: user, item_diff: item_diff }
        let(:item_diff) { { russian: ['a', 'b'] } }

        describe 'common change' do
          it { is_expected.to be_able_to :create, version }
          it { is_expected.to be_able_to :destroy, version }
          it { is_expected.to_not be_able_to :accept, version }

          context 'banned user' do
            let(:user) { build_stubbed :user, :user, :banned }
            it { is_expected.to_not be_able_to :create, version }
            it { is_expected.to_not be_able_to :destroy, version }
          end

          context 'not_trusted_version_changer user' do
            let(:user) { build_stubbed :user, :not_trusted_version_changer }
            it { is_expected.to_not be_able_to :create, version }
            it { is_expected.to_not be_able_to :destroy, version }
          end

          context 'not week_registered user' do
            let(:user) { build_stubbed :user }
            it { is_expected.to_not be_able_to :create, version }
            it { is_expected.to_not be_able_to :destroy, version }
          end
        end

        describe 'significant change' do
          context 'common field' do
            let(:item_diff) { { name: ['a', 'b'] } }
            it { is_expected.to_not be_able_to :create, version }
          end

          context 'image' do
            let(:item_diff) { { image: [prior_image, 'zxcvbn'] } }

            context 'exists' do
              let(:prior_image) { 'zxc' }
              it { is_expected.to_not be_able_to :create, version }
            end

            context 'not exists' do
              let(:prior_image) { nil }
              it { is_expected.to be_able_to :create, version }
            end
          end
        end

        it { is_expected.to be_able_to :show, version }
        it { is_expected.to be_able_to :tooltip, version }
        it { is_expected.to be_able_to :destroy, version }
        it { is_expected.to_not be_able_to :manage, version }

        context 'role version' do
          let(:version) { build_stubbed :role_version, user: user }

          it { is_expected.to_not be_able_to :create, version }
          it { is_expected.to be_able_to :show, version }
          it { is_expected.to be_able_to :tooltip, version }
          it { is_expected.to be_able_to :destroy, version }
          it { is_expected.to_not be_able_to :manage, version }
        end
      end

      describe "another user's version" do
        it { is_expected.to be_able_to :show, version }
        it { is_expected.to be_able_to :tooltip, version }
        it { is_expected.to_not be_able_to :create, version }
        it { is_expected.to_not be_able_to :destroy, version }
        it { is_expected.to_not be_able_to :manage, version }
      end
    end

    context 'trusted_version_changer' do
      let(:user) { build_stubbed :user, :trusted_version_changer, :week_registered }

      describe 'own version' do
        let(:version) do
          build_stubbed :version,
            user: user,
            item_diff: item_diff
        end
        let(:item_diff) { { russian: ['a', 'b'] } }
        it { is_expected.to be_able_to :auto_accept, version }
      end

      describe 'user version' do
        it { is_expected.to_not be_able_to :auto_accept, version }
      end
    end

    context 'version_texts_moderator' do
      let(:user) { build_stubbed :user, :version_texts_moderator }
      let(:version) do
        build_stubbed :version,
          item: item,
          user: version_user,
          item_diff: item_diff
      end
      let(:item) { build_stubbed :anime }
      let(:item_diff) do
        [
          { name: ['a', 'b'] },
          { russian: ['a', 'b'] },
          { description_ru: ['a', 'b'] }
        ].sample
      end
      let(:version_user) { user }

      it { is_expected.to be_able_to :manage, version }
      it { is_expected.to be_able_to :auto_accept, version }

      context 'not only fansubbers/fandubbers changed' do
        let(:item_diff) { { name: %w[a b], english: %w[a b] } }
        it { is_expected.to_not be_able_to :auto_accept, version }
      end

      context 'not fandubbers changed' do
        let(:item_diff) { { english: %w[a b] } }
        it { is_expected.to_not be_able_to :manage, version }
      end
    end

    context 'version_fansub_moderator' do
      let(:user) { build_stubbed :user, :version_fansub_moderator }
      let(:version) do
        build_stubbed :version,
          item: item,
          user: version_user,
          item_diff: item_diff
      end
      let(:item) { build_stubbed :anime }
      let(:item_diff) { [{ fandubbers: ['a', 'b'] }, { fansubbers: ['a', 'b'] }].sample }
      let(:version_user) { user }

      it { is_expected.to be_able_to :manage, version }
      it { is_expected.to be_able_to :auto_accept, version }

      context 'not only fansubbers/fandubbers changed' do
        let(:item_diff) { { fandubbers: %w[a b], name: %w[a b] } }
        it { is_expected.to_not be_able_to :manage, version }
      end

      context 'not fandubbers changed' do
        let(:item_diff) { { name: %w[a b] } }
        it { is_expected.to_not be_able_to :manage, version }
      end
    end

    context 'trusted_attached_video_changer' do
      let(:user) { build_stubbed :user, :trusted_attached_video_changer, :week_registered }
      let(:version) do
        [
          build_stubbed(:video_version, item: item, user: version_user),
          build_stubbed(:version, item: video, user: version_user)
        ].sample
      end
      let(:item) { build_stubbed :anime }
      let(:video) { build_stubbed :video, anime: item }
      let(:version_user) { user }

      it { is_expected.to be_able_to :auto_accept, version }

      context 'not user version' do
        let(:version_user) { build_stubbed :user, :user }
        it { is_expected.to_not be_able_to :auto_accept, version }
      end

      context 'not video version' do
        let(:version) { build_stubbed :version, item: item, user: version_user }
        it { is_expected.to_not be_able_to :auto_accept, version }
      end
    end

    context 'video_moderator' do
      let(:user) { build_stubbed :user, :video_moderator }
      let(:version) { build_stubbed :version, user: user, item: item }

      context 'not anime video' do
        let(:item) { build_stubbed :anime }
        it { is_expected.to_not be_able_to :manage, version }
        it { is_expected.to be_able_to :minor_change, version }
        it { is_expected.to_not be_able_to :major_change, version }
      end

      context 'anime video' do
        let(:item) { build_stubbed :anime_video }
        it { is_expected.to be_able_to :manage, version }
      end
    end
  end

  it_behaves_like :antispam_concern, :version
end
