require 'spec_helper'

describe UserRate do
  describe :relations do
    it { should belong_to :target }
    it { should belong_to :user }
    it { should belong_to :anime }
    it { should belong_to :manga }
  end

  describe :callbacks do
    context :create do
      let(:user_rate) { build :user_rate, status: 0 }
      after { user_rate.save }

      it { expect(user_rate).to receive :log_created }
      it { expect(user_rate).to receive :smart_process_changes }
    end

    context :update do
      let(:user_rate) { create :user_rate, status: 0 }
      after { user_rate.update status: 1 }

      it { expect(user_rate).to_not receive :log_created }
      it { expect(user_rate).to receive :smart_process_changes }
    end

    context :destroy do
      let(:user_rate) { create :user_rate, status: 0 }
      after { user_rate.destroy }

      it { expect(user_rate).to receive :log_deleted }
      it { expect(user_rate).to_not receive :smart_process_changes }
    end
  end

  describe :instance_methods do
    let(:episodes) { 10 }
    let(:volumes) { 15 }
    let(:chapters) { 100 }

    describe :anime? do
      subject { user_rate.anime? }

      context :anime do
        let(:user_rate) { build :user_rate, target_type: 'Anime' }
        it { should be true }
      end

      context :manga do
        let(:user_rate) { build :user_rate, target_type: 'Manga' }
        it { should be false }
      end
    end

    describe :manga? do
      subject { user_rate.manga? }

      context :anime do
        let(:user_rate) { build :user_rate, target_type: 'Anime' }
        it { should be false }
      end

      context :manga do
        let(:user_rate) { build :user_rate, target_type: 'Manga' }
        it { should be true }
      end
    end

    describe :smart_process_changes do
      let(:user_rate) { build :user_rate, target: build_stubbed(:anime), status: 1 }
      after { user_rate.save }

      it { expect(user_rate).to receive :status_changed }
    end

    describe :status_changed do
      subject!(:user_rate) { create :user_rate, status, target: target }
      before do
        expect(UserHistory).to receive(:add).with(
          user_rate.user,
          user_rate.target,
          UserHistoryAction::Status,
          UserRateStatus.get(UserRateStatus::Planned),
          build_stubbed(:user_rate, status).status
        )

        user_rate.update status: UserRateStatus.get(UserRateStatus::Planned)
      end

      context :anime do
        let(:target) { build_stubbed :anime, episodes: 20 }

        context :completed do
          let(:status) { :completed }
          its(:episodes) { should eq target.episodes }
        end

        context :watching do
          let(:status) { :watching }
          its(:episodes) { should eq 0 }
        end
      end

      context :manga do
        let(:target) { build_stubbed :manga, volumes: 20, chapters: 25 }

        context :completed do
          let(:status) { :completed }
          its(:volumes) { should eq target.volumes }
          its(:chapters) { should eq target.chapters }
        end

        context :watching do
          let(:status) { :watching }
          its(:volumes) { should eq 0 }
          its(:chapters) { should eq 0 }
        end
      end
    end

    describe :score_changed do
      subject!(:user_rate) { create :user_rate, score: initial_value }
      let(:initial_value) { 5 }

      context :nil_value do
        let(:initial_value) { 0 }
        let(:new_value) { nil }

        before { expect(UserHistory).to_not receive :add }
        before { user_rate.update score: new_value }

        its(:score) { should eq initial_value }
      end

      context :regular_change do
        let(:new_value) { 8 }

        before { expect(UserHistory).to receive(:add).with user_rate.user, user_rate.target, UserHistoryAction::Rate, new_value, initial_value }
        before { user_rate.update score: new_value }

        its(:score) { should eq new_value }
      end

      context :negative_value do
        let(:new_value) { -1 }

        before { expect(UserHistory).to_not receive :add }
        before { user_rate.update score: new_value }

        its(:score) { should eq initial_value }
      end

      context :big_value do
        let(:new_value) { UserRate::MAXIMUM_SCORE + 1 }

        before { expect(UserHistory).to_not receive :add }
        before { user_rate.update score: new_value }

        its(:score) { should eq initial_value }
      end
    end

    describe :counter_changed do
      subject!(:user_rate) { create :user_rate, target: target, episodes: initial_value, volumes: initial_value, chapters: initial_value }

      let(:initial_value) { 1 }
      let(:target_value) { 99 }

      context :anime do
        let(:target) { build_stubbed :anime, episodes: target_value }
        before { user_rate.update episodes: new_value }

        context :regular_change do
          before { expect(UserHistory).to receive(:add).with user_rate.user, user_rate.target, UserHistoryAction::Episodes, newest_value, new_value }
          before { user_rate.update episodes: 7 }

          let(:initial_value) { 3 }
          let(:new_value) { 5 }
          let(:newest_value) { 7 }

          its(:episodes) { should eq newest_value }
        end

        context :maximum_number do
          let(:target_value) { 0 }
          let(:new_value) { UserRate::MAXIMUM_EPISODES + 1 }
          its(:episodes) { should eq initial_value }
        end

        context :nil_number do
          let(:new_value) { nil }
          its(:episodes) { should eq 0 }
        end

        context :negative_number do
          let(:new_value) { -1 }
          its(:episodes) { should eq 0 }
        end

        context :larger_than_target_number do
          let(:target_value) { 99 }
          let(:new_value) { 100 }
          its(:episodes) { should eq target.episodes }
        end

        context :full_watch do
          let(:new_value) { target_value }
          its(:episodes) { should eq target_value }
          its(:completed?) { should be true }
        end

        context :starting_watching do
          let(:initial_value) { 0 }
          let(:new_value) { 5 }
          its(:watching?) { should be true }
        end

        context :stopped_watching do
          let(:initial_value) { 1 }
          let(:new_value) { 0 }
          its(:planned?) { should be true }
        end
      end

      context :manga do
        let(:other_value) { 200 }

        describe :volumes do
          let(:target) { build_stubbed :manga, volumes: target_value, chapters: other_value }
          before { user_rate.update volumes: new_value }

          context :full_read do
            let(:new_value) { target_value }
            its(:volumes) { should eq target_value }
            its(:chapters) { should eq other_value }
            its(:completed?) { should be true }
          end

          context :zero_volumes do
            let(:new_value) { 0 }
            its(:volumes) { should eq 0 }
            its(:chapters) { should eq 0 }
          end
        end

        describe :chapters do
          let(:target) { build_stubbed :manga, volumes: other_value, chapters: target_value }
          before { user_rate.update chapters: new_value }

          context :full_read do
            let(:new_value) { target_value }
            its(:volumes) { should eq other_value }
            its(:chapters) { should eq target_value }
            its(:completed?) { should be true }
          end

          context :zero_chapters do
            let(:new_value) { 0 }
            its(:volumes) { should eq 0 }
            its(:chapters) { should eq 0 }
          end
        end
      end
    end

    describe :log_created do
      subject(:user_rate) { build :user_rate, target: build_stubbed(:anime), user: build_stubbed(:user) }
      after { user_rate.save }
      before { expect(UserHistory).to receive(:add).with user_rate.user, user_rate.target, UserHistoryAction::Add }
    end

    describe :log_deleted do
      subject!(:user_rate) { create :user_rate, target: build_stubbed(:anime), user: build_stubbed(:user) }
      after { user_rate.destroy }
      before { expect(UserHistory).to receive(:add).with user_rate.user, user_rate.target, UserHistoryAction::Delete }
    end

    describe :planned? do
      subject(:rate) { build_stubbed :user_rate, :planned }

      its(:planned?) { should be true }
      its(:watching?) { should be false }
      its(:completed?) { should be false }
      its(:on_hold?) { should be false }
      its(:dropped?) { should be false }
    end

    describe :watching? do
      subject(:rate) { build_stubbed :user_rate, status: UserRateStatus.get(UserRateStatus::Watching) }

      its(:planned?) { should be false }
      its(:watching?) { should be true }
      its(:completed?) { should be false }
      its(:on_hold?) { should be false }
      its(:dropped?) { should be false }
    end

    describe :completed? do
      subject(:rate) { build_stubbed :user_rate, status: UserRateStatus.get(UserRateStatus::Completed) }

      its(:planned?) { should be false }
      its(:watching?) { should be false }
      its(:completed?) { should be true }
      its(:on_hold?) { should be false }
      its(:dropped?) { should be false }
    end

    describe :on_hold? do
      subject(:rate) { build_stubbed :user_rate, status: UserRateStatus.get(UserRateStatus::OnHold) }

      its(:planned?) { should be false }
      its(:watching?) { should be false }
      its(:completed?) { should be false }
      its(:on_hold?) { should be true }
      its(:dropped?) { should be false }
    end

    describe :dropped? do
      subject(:rate) { build_stubbed :user_rate, status: UserRateStatus.get(UserRateStatus::Dropped) }

      its(:planned?) { should be false }
      its(:watching?) { should be false }
      its(:completed?) { should be false }
      its(:on_hold?) { should be false }
      its(:dropped?) { should be true }
    end

    describe :text_html do
      subject { build :user_rate, text: "[b]test[/b]\ntest" }
      its(:text_html) { should eq '<strong>test</strong><br />test' }
    end
  end
end
