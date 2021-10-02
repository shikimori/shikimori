describe UserRate do
  describe 'relations' do
    it { is_expected.to belong_to :target }
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to(:anime).optional }
    it { is_expected.to belong_to(:manga).optional }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :target }
    it { is_expected.to validate_presence_of :user }
    it { is_expected.to validate_presence_of :status }
    it { is_expected.to validate_length_of :text }
  end

  describe 'callbacks' do
    let!(:user_rate) { nil }
    before do
      allow(user_rate).to receive :log_created
      allow(user_rate).to receive :smart_process_changes
      allow(user_rate).to receive :log_deleted
    end

    context '#create' do
      let(:user_rate) { build :user_rate, status: 0 }
      subject! { user_rate.save! }

      it do
        expect(user_rate).to have_received :log_created
        expect(user_rate).to have_received :smart_process_changes
        expect(user_rate).to_not have_received :log_deleted
      end

      context '.wo_logging' do
        around(:each) do |example|
          UserRate.wo_logging { example.run }
        end

        it do
          expect(user_rate).to_not have_received :log_created
          expect(user_rate).to have_received :smart_process_changes
        end
      end
    end

    context '#update' do
      let!(:user_rate) { create :user_rate, status: 0 }
      subject! { user_rate.update status: 1 }

      it do
        expect(user_rate).to_not have_received :log_created
        expect(user_rate).to have_received :smart_process_changes
        expect(user_rate).to_not have_received :log_deleted
      end
    end

    context '#destroy' do
      let(:user_rate) { create :user_rate, status: 0 }
      subject! { user_rate.destroy }

      it do
        expect(user_rate).to_not have_received :log_created
        expect(user_rate).to have_received :log_deleted
        expect(user_rate).to_not have_received :smart_process_changes
      end

      context '@is_skip_logging' do
        around(:each) do |example|
          UserRate.wo_logging { example.run }
        end

        it do
          expect(user_rate).to_not have_received :log_created
          expect(user_rate).to_not have_received :log_deleted
          expect(user_rate).to_not have_received :smart_process_changes
        end
      end
    end
  end

  describe 'instance methods' do
    let(:episodes) { 10 }
    let(:volumes) { 15 }
    let(:chapters) { 100 }

    describe '#text=' do
      let(:user_rate) { build :user_rate, text: 'a' * (UserRate::MAXIMUM_TEXT_SIZE + 1) }
      it { expect(user_rate.text).to have(UserRate::MAXIMUM_TEXT_SIZE).items }
    end

    describe '#anime?' do
      subject { user_rate.anime? }

      context 'anime' do
        let(:user_rate) { build :user_rate, target_type: 'Anime' }
        it { is_expected.to be true }
      end

      context 'manga' do
        let(:user_rate) { build :user_rate, target_type: 'Manga' }
        it { is_expected.to be false }
      end
    end

    describe '#manga?' do
      subject { user_rate.manga? }

      context 'anime' do
        let(:user_rate) { build :user_rate, target_type: 'Anime' }
        it { is_expected.to be false }
      end

      context 'manga' do
        let(:user_rate) { build :user_rate, target_type: 'Manga' }
        it { is_expected.to be true }
      end
    end

    describe '#smart_process_changes' do
      context 'onhold with episode' do
        subject(:user_rate) { create :user_rate, :on_hold, target: build_stubbed(:anime, episodes: 99), episodes: 6 }
        it { is_expected.to be_on_hold }
        its(:episodes) { is_expected.to eq 6 }
      end

      context 'dropped with full episode' do
        subject(:user_rate) { create :user_rate, :dropped, target: build_stubbed(:anime, episodes: 3), episodes: 3 }
        it { is_expected.to be_dropped }
        its(:episodes) { is_expected.to eq 3 }
      end

      context 'dropped with parital episode' do
        subject(:user_rate) { create :user_rate, :dropped, target: build_stubbed(:anime, episodes: 3), episodes: 2 }
        it { is_expected.to be_dropped }
        its(:episodes) { is_expected.to eq 2 }
      end

      context 'planned with full episode' do
        subject { create :user_rate, :planned, target: build_stubbed(:anime, episodes: 3), episodes: 3 }
        it { is_expected.to be_completed }
        its(:episodes) { is_expected.to eq 3 }
      end

      describe 'status change' do
        context 'anime' do
          let(:user_rate) { build :user_rate, :watching, target: build_stubbed(:anime) }
          after { user_rate.save }
          it { expect(user_rate).to receive :anime_status_changed }
        end

        context 'manga' do
          let(:user_rate) { build :user_rate, :watching, target: build_stubbed(:manga) }
          after { user_rate.save }
          it { expect(user_rate).to receive :manga_status_changed }
        end
      end

      describe 'nil rewatches' do
        let(:user_rate) { build :user_rate, :watching, target: build_stubbed(:anime), rewatches: nil }
        before { user_rate.save }
        its(:rewatches) { is_expected.to be_zero }
      end
    end

    describe '#anime_status_changed, #manga_status_changed, #counter_changed' do
      let(:target) { build_stubbed :anime, episodes: 20 }
      before { allow(UserHistory).to receive :add }

      context 'to watching with episodes' do
        let(:old_status) { :planned }
        let(:new_status) { :watching }
        let(:new_episodes) { 1 }
        let(:update_params) { { status: new_status, episodes: new_episodes } }

        subject(:user_rate) { create :user_rate, old_status, target: target }
        before { user_rate.update update_params }

        it do
          expect(user_rate.episodes).to eq new_episodes
          expect(user_rate.status).to eq new_status.to_s

          expect(UserHistory).to have_received(:add).with(
            user_rate.user,
            user_rate.target,
            UserHistoryAction::STATUS,
            UserRate.statuses[new_status],
            UserRate.statuses[old_status]
          ).ordered
          expect(UserHistory).to have_received(:add).with(
            user_rate.user,
            user_rate.target,
            UserHistoryAction::EPISODES,
            new_episodes,
            0
          ).ordered
        end
      end

      context 'added to planned with episode' do
        subject(:user_rate) { create :user_rate, :planned, episodes: 10, target: target }
        it do
          expect(user_rate.episodes).to eq 10
          expect(user_rate).to be_planned
        end
      end
    end

    describe '#status_changed' do
      before do
        expect(UserHistory).to receive(:add).with(
          user_rate.user,
          user_rate.target,
          UserHistoryAction::STATUS,
          UserRate.statuses[new_status],
          UserRate.statuses[old_status]
        )
      end

      subject(:user_rate) { create :user_rate, old_status, target: target }
      let(:update_params) { { status: new_status } }
      before { user_rate.update update_params }

      describe 'to planned' do
        let(:new_status) { :planned }

        context 'anime' do
          let(:target) { build_stubbed :anime, episodes: 20 }

          context 'completed' do
            let(:old_status) { :completed }
            its(:episodes) { is_expected.to eq target.episodes }
          end

          context 'watching' do
            let(:old_status) { :watching }
            its(:episodes) { is_expected.to eq 0 }
          end
        end

        context 'manga' do
          let(:target) { build_stubbed :manga, volumes: 20, chapters: 25 }

          context 'completed' do
            let(:old_status) { :completed }
            its(:volumes) { is_expected.to eq target.volumes }
            its(:chapters) { is_expected.to eq target.chapters }
          end

          context 'watching' do
            let(:old_status) { :watching }
            its(:volumes) { is_expected.to eq 0 }
            its(:chapters) { is_expected.to eq 0 }
          end
        end
      end

      context 'to rewatching' do
        let(:old_status) { :completed }
        let(:new_status) { :rewatching }

        context 'anime' do
          let(:target) { build_stubbed :anime, episodes: 20 }
          its(:episodes) { is_expected.to eq 0 }
        end

        context 'manga' do
          let(:target) { build_stubbed :manga, volumes: 20, chapters: 20 }
          its(:volumes) { is_expected.to eq 0 }
          its(:chapters) { is_expected.to eq 0 }
        end
      end

      context 'to rewatching with episodes' do
        let(:target) { build_stubbed :anime, episodes: 20 }
        let(:old_status) { :completed }
        let(:new_status) { :rewatching }
        let(:new_episodes) { 10 }
        let(:update_params) { { status: new_status, episodes: new_episodes } }

        its(:episodes) { is_expected.to eq new_episodes }
      end

      context 'to onhold with 0 episodes from completed' do
        let(:target) { build_stubbed :anime, episodes: 20 }
        let(:old_status) { :completed }
        let(:new_status) { :on_hold }
        let(:new_episodes) { 0 }
        let(:update_params) { { status: new_status, episodes: new_episodes } }

        it { is_expected.to be_on_hold }
        its(:episodes) { is_expected.to eq 0 }
      end

      context 'to completed for ongoing w/o episodes' do
        subject(:user_rate) { create :user_rate, old_status, episodes: old_episodes, target: target }
        let(:target) { build_stubbed :anime, :ongoing, episodes: 0 }

        let(:old_episodes) { 3 }
        let(:old_status) { :watching }
        let(:new_status) { :completed }
        let(:update_params) { { status: new_status } }

        it { is_expected.to be_completed }
        its(:episodes) { is_expected.to eq old_episodes }
      end
    end

    describe '#score_changed' do
      subject!(:user_rate) { create :user_rate, score: old_value }
      let(:old_value) { 5 }

      context 'nil value' do
        let(:old_value) { 0 }
        let(:new_value) { nil }

        before { expect(UserHistory).to_not receive :add }
        before { user_rate.update score: new_value }

        its(:score) { is_expected.to eq old_value }
      end

      context 'regular change' do
        let(:new_value) { 8 }

        before { expect(UserHistory).to receive(:add).with user_rate.user, user_rate.target, UserHistoryAction::RATE, new_value, old_value }
        before { user_rate.update score: new_value }

        its(:score) { is_expected.to eq new_value }
      end

      context 'negative value' do
        let(:new_value) { -1 }

        before { expect(UserHistory).to_not receive :add }
        before { user_rate.update score: new_value }

        its(:score) { is_expected.to eq old_value }
      end

      context 'big value' do
        let(:new_value) { UserRate::MAXIMUM_SCORE + 1 }

        before { expect(UserHistory).to_not receive :add }
        before { user_rate.update score: new_value }

        its(:score) { is_expected.to eq old_value }
      end
    end

    describe '#counter_changed' do
      subject!(:user_rate) do
        create :user_rate,
          target: target,
          episodes: old_value,
          volumes: old_value,
          chapters: old_value,
          status: old_status
      end

      let(:old_value) { 1 }
      let(:old_status) { :planned }
      let(:target_value) { 99 }

      context 'anime' do
        let(:target) { build_stubbed :anime, episodes: target_value }
        before { user_rate.update episodes: new_value }

        context 'regular_change' do
          before { expect(UserHistory).to receive(:add).with user_rate.user, user_rate.target, UserHistoryAction::EPISODES, newest_value, new_value }
          before { user_rate.update episodes: 7 }

          let(:old_value) { 3 }
          let(:new_value) { 5 }
          let(:newest_value) { 7 }

          its(:episodes) { is_expected.to eq newest_value }
        end

        context 'maximum number' do
          let(:target_value) { 0 }
          let(:new_value) { UserRate::MAXIMUM_EPISODES + 1 }
          its(:episodes) { is_expected.to eq old_value }
        end

        context 'nil number' do
          let(:new_value) { nil }
          its(:episodes) { is_expected.to eq 0 }
        end

        context 'negative number' do
          let(:new_value) { -1 }
          its(:episodes) { is_expected.to eq 0 }
        end

        context 'greater than target number' do
          let(:target_value) { 99 }
          let(:new_value) { 100 }
          its(:episodes) { is_expected.to eq target.episodes }
        end

        context 'started watching' do
          let(:old_value) { 0 }
          let(:new_value) { 5 }
          it { is_expected.to be_watching }
        end

        context 'finished watching' do
          let(:new_value) { target_value }
          its(:episodes) { is_expected.to eq target_value }
          it { is_expected.to be_completed }
        end

        context 'stopped watching' do
          let(:old_value) { 1 }
          let(:new_value) { 0 }
          it { is_expected.to be_planned }
        end

        context 'rewatching' do
          let(:old_status) { :rewatching }

          context 'started watching' do
            let(:old_value) { 0 }
            let(:new_value) { 1 }

            its(:episodes) { is_expected.to eq new_value }
            it { is_expected.to be_rewatching }
          end

          context 'finished watching' do
            let(:new_value) { target_value }

            its(:episodes) { is_expected.to eq target_value }
            its(:rewatches) { is_expected.to eq 1 }
            it { is_expected.to be_completed }
          end
        end

        context 'dropped' do
          let(:old_status) { :dropped }

          context 'started watching' do
            let(:old_value) { 0 }
            let(:new_value) { 1 }

            its(:episodes) { is_expected.to eq new_value }
            it { is_expected.to be_dropped }
          end

          context 'finished watching' do
            let(:new_value) { target_value }

            its(:episodes) { is_expected.to eq target_value }
            it { is_expected.to be_completed }
          end
        end
      end

      context 'manga' do
        let(:other_value) { 200 }

        describe 'volumes' do
          let(:target) { build_stubbed :manga, volumes: target_value, chapters: other_value }
          before { user_rate.update volumes: new_value }

          context 'full read' do
            let(:new_value) { target_value }
            its(:volumes) { is_expected.to eq target_value }
            its(:chapters) { is_expected.to eq other_value }
            it { is_expected.to be_completed }
          end

          context 'zero volumes' do
            let(:new_value) { 0 }
            its(:volumes) { is_expected.to eq 0 }
            its(:chapters) { is_expected.to eq 0 }
          end
        end

        describe 'chapters' do
          let(:target) { build_stubbed :manga, volumes: other_value, chapters: target_value }
          before { user_rate.update chapters: new_value }

          context 'full read' do
            let(:new_value) { target_value }
            its(:volumes) { is_expected.to eq other_value }
            its(:chapters) { is_expected.to eq target_value }
            it { is_expected.to be_completed }
          end

          context 'zero chapters' do
            let(:new_value) { 0 }
            its(:volumes) { is_expected.to eq 0 }
            its(:chapters) { is_expected.to eq 0 }
          end
        end
      end
    end

    describe '#log_created' do
      subject(:user_rate) do
        build :user_rate,
          target: build_stubbed(:anime),
          user: seed(:user),
          status: status,
          score: score
      end
      before { allow(UserHistory).to receive :add }
      subject! { user_rate.save }

      context 'no status, no score' do
        let(:status) { :planned }
        let(:score) { 0 }
        it do
          expect(UserHistory)
            .to have_received(:add)
            .with user_rate.user, user_rate.target, UserHistoryAction::ADD
        end
      end

      context 'status and scored' do
        let(:status) { :completed }
        let(:score) { 5 }
        it do
          expect(UserHistory)
            .to have_received(:add)
            .with(user_rate.user, user_rate.target, UserHistoryAction::ADD)
            .ordered
          expect(UserHistory)
            .to have_received(:add)
            .with(
              user_rate.user,
              user_rate.target,
              UserHistoryAction::STATUS,
              UserRate.statuses['completed']
            )
            .ordered
          expect(UserHistory)
            .to have_received(:add)
            .with(user_rate.user, user_rate.target, UserHistoryAction::RATE, 5)
            .ordered
        end
      end
    end

    describe '#log_deleted' do
      let(:user_rate) do
        create :user_rate,
          target: build_stubbed(:anime),
          user: seed(:user)
      end
      before { allow(UserHistory).to receive :add }
      subject! { user_rate.destroy }
      it do
        expect(UserHistory)
          .to have_received(:add)
          .with(user_rate.user, user_rate.target, UserHistoryAction::DELETE)
      end
    end

    describe '#text_html' do
      subject { build :user_rate, text: "[b]test[/b]\ntest" }
      its(:text_html) { is_expected.to eq '<strong>test</strong><br>test' }
    end

    describe '#status_name' do
      subject { build :user_rate, target_type: 'Anime' }
      its(:status_name) { is_expected.to eq 'Запланировано' }
    end
  end

  describe 'edge cases' do
    context '0 ep completed -> 1ep completed' do
      let(:user_rate) do
        create :user_rate,
          episodes: 0,
          status: :completed,
          target: anime
      end
      let(:anime) { create :anime, :movie, episodes: 1 }
      before { user_rate.update_column :episodes, 0 }
      subject! { user_rate.update episodes: 1 }

      it do
        expect(user_rate).to have_attributes(
          status: 'completed',
          episodes: 1,
          rewatches: 0
        )
      end
    end
  end

  describe 'permissions' do
    let(:user_rate) { build_stubbed :user_rate, user: user }
    subject { Ability.new user }

    context 'owner' do
      let(:user) { build_stubbed :user, :user }
      it { is_expected.to be_able_to :manage, user_rate }
    end

    context 'guest' do
      let(:user) { nil }
      it { is_expected.to be_able_to :read, user_rate }
      it { is_expected.to_not be_able_to :manage, user_rate }
    end

    context 'user' do
      let(:user) { build_stubbed :user, :user }
      let(:user_2) { build_stubbed :user }
      let(:user_rate) { build_stubbed :user_rate, user: user_2 }

      it { is_expected.to be_able_to :read, user_rate }
      it { is_expected.to_not be_able_to :manage, user_rate }
    end
  end
end
