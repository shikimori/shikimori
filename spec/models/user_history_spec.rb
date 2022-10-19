describe UserHistory do
  describe 'relations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to(:anime).optional }
    it { is_expected.to belong_to(:manga).optional }
  end

  describe 'class methods' do
    def touch entry, time
      entry.update_columns(
        created_at: time,
        updated_at: time
      )
    end

    describe '.add' do
      let(:user_2) { create :user, id: 2 }

      let(:kind) { %i[anime manga ranobe].sample }
      let(:anime) { build_stubbed kind, id: 1 }
      let(:anime_2) { build_stubbed kind, id: 2 }

      context 'added anime successfully' do
        subject { UserHistory.add user, anime, UserHistoryAction::ADD }
        it do
          expect { subject }.to change(UserHistory, :count).by 1
          expect(UserHistory.last.action).to eq UserHistoryAction::ADD
        end
      end

      context 'added anime and' do
        before { UserHistory.add user, anime, UserHistoryAction::ADD }

        context 'again added anime' do
          subject { UserHistory.add user, anime, UserHistoryAction::ADD }
          it do
            expect { subject }.to_not change UserHistory, :count
          end
        end

        context 'again added anime and then added anime_2' do
          subject do
            UserHistory.add user, anime, UserHistoryAction::ADD
            UserHistory.add user, anime_2, UserHistoryAction::ADD
          end
          it do
            expect { subject }.to change(UserHistory, :count).by 1
          end
        end

        context 'another user added anime too' do
          subject { UserHistory.add user_2, anime, UserHistoryAction::ADD }
          it do
            expect { subject }.to change(UserHistory, :count).by 1
          end
        end

        context 'then deleted it in UserHistory::DELETE_BACKWARD_CHECK_INTERVAL' do
          before do
            touch UserHistory.last, UserHistory::DELETE_BACKWARD_CHECK_INTERVAL.ago - 1.minute
          end
          subject { UserHistory.add user, anime, UserHistoryAction::DELETE }

          it do
            expect { subject }.to change(UserHistory, :count).by(-1)
          end
        end

        context 'added anime_2 and then deleted it after UserHistory::DELETE_BACKWARD_CHECK_INTERVAL' do
          before do
            touch UserHistory.last, UserHistory::DELETE_BACKWARD_CHECK_INTERVAL.ago - 1.minute
          end
          subject do
            UserHistory.add user, anime_2, UserHistoryAction::ADD
            UserHistory.add user, anime, UserHistoryAction::DELETE
          end

          it do
            expect { subject }.to change(UserHistory, :count).by 2
            expect(UserHistory.last.action).to eq UserHistoryAction::DELETE
          end
        end

        context 'did some actions with it and with other animes and then deleted first added anime in UserHistory::DELETE_BACKWARD_CHECK_INTERVAL' do
          before do
            touch UserHistory.last, UserHistory::DELETE_BACKWARD_CHECK_INTERVAL.ago + 1.minute
          end
          subject do
            # and did some actions with it and with other animes
            UserHistory.add user, anime, UserHistoryAction::RATE, 1
            touch UserHistory.last, UserHistory::DELETE_BACKWARD_CHECK_INTERVAL.ago + 2.minutes

            UserHistory.add user, anime_2, UserHistoryAction::ADD
            touch UserHistory.last, UserHistory::DELETE_BACKWARD_CHECK_INTERVAL.ago + 3.minutes

            # and then deleted first added anime
            UserHistory.add user, anime, UserHistoryAction::DELETE
          end
          it do
            expect { subject }.to_not change UserHistory, :count
          end
        end

        context 'did some actions with it and with other animes and then deleted first added anime after UserHistory::DELETE_BACKWARD_CHECK_INTERVAL' do
          before do
            touch UserHistory.last, UserHistory::DELETE_BACKWARD_CHECK_INTERVAL.ago - 1.minute
          end
          subject do
            # and did some actions with it and with other animes
            UserHistory.add user, anime, UserHistoryAction::RATE, 1
            touch UserHistory.last, 5.minutes.ago

            UserHistory.add user, anime_2, UserHistoryAction::ADD
            touch UserHistory.last, 4.minutes.ago

            # and then deleted first added anime
            UserHistory.add user, anime, UserHistoryAction::DELETE
          end

          it do
            expect { subject }.to change(UserHistory, :count).by 2
          end
        end

        context 'added anime_2 and deleted anime and then added it again' do
          before do
            touch UserHistory.last, UserHistory::DELETE_BACKWARD_CHECK_INTERVAL.ago + 1.minute
            UserHistory.add user, anime_2, UserHistoryAction::DELETE
          end
          subject do
            UserHistory.add user, anime, UserHistoryAction::DELETE
            touch UserHistory.last, UserHistory::DELETE_BACKWARD_CHECK_INTERVAL.ago - 1.minute
            UserHistory.add user, anime, UserHistoryAction::ADD
          end
          it do
            expect { subject }.to_not change UserHistory, :count
          end
        end
      end

      context 'rated anime' do
        subject { UserHistory.add user, anime, UserHistoryAction::RATE, 5 }
        it do
          expect { subject }.to change(UserHistory, :count).by 1

          expect(UserHistory.last.action).to eq UserHistoryAction::RATE
          expect(UserHistory.last.value).to eq '5'
        end
      end

      context 'rate with score greater then 10 should be treated like 10' do
        subject { UserHistory.add user, anime, UserHistoryAction::RATE, 100000000000000 }
        it do
          expect { subject }.to change(UserHistory, :count).by 1

          expect(UserHistory.last.action).to eq UserHistoryAction::RATE
          expect(UserHistory.last.value).to eq '10'
        end
      end

      context 'rate with score less then 0 should be treated like 0' do
        before { UserHistory.add user, anime, UserHistoryAction::RATE, 1 }
        subject do
          UserHistory.add user, anime, UserHistoryAction::RATE, -1
        end
        it do
          expect { subject }.to change(UserHistory, :count).by(-1)
        end
      end

      context 'rated anime with 0 and prior rate was 0' do
        subject { UserHistory.add user, anime, UserHistoryAction::RATE, 0, 0 }
        it do
          expect(-> {
          }).to_not change UserHistory, :count
        end
      end

      context 'rated anime with 0 and prior rate was not 0' do
        subject { UserHistory.add user, anime, UserHistoryAction::RATE, 0, 1 }
        it do
          expect { subject }.to change(UserHistory, :count).by 1
        end
      end

      context 'rated anime and' do
        let(:prior_rate) { 5 }
        before do
          UserHistory.add user, anime, UserHistoryAction::RATE, prior_rate, nil
        end

        context 'after BACKWARD_CHECK_INTERVAL rated it again with prior_rate+1 and rated it again with prior_rate' do
          before do
            touch UserHistory.last, UserHistory::BACKWARD_CHECK_INTERVAL.ago - 1.minute
          end
          subject do
            UserHistory.add user, anime, UserHistoryAction::RATE, prior_rate + 1, prior_rate
            UserHistory.add user, anime, UserHistoryAction::RATE, prior_rate, prior_rate + 1
          end
          it do
            expect { subject }.to_not change UserHistory, :count
          end
        end

        context 'rated it again with 0' do
          subject { UserHistory.add user, anime, UserHistoryAction::RATE, 0, prior_rate }
          it do
            expect { subject }.to change(UserHistory, :count).by(-1)
          end
        end

        context 'rated it again with the same value' do
          subject { UserHistory.add user, anime, UserHistoryAction::RATE, 5, prior_rate }
          it do
            expect { subject }.to_not change UserHistory, :count
            expect(UserHistory.last.action).to eq UserHistoryAction::RATE
            expect(UserHistory.last.value).to eq '5'
          end
        end

        context 'rated it again with another value' do
          subject { UserHistory.add user, anime, UserHistoryAction::RATE, 6, prior_rate }
          it do
            expect { subject }.to_not change UserHistory, :count
            expect(UserHistory.last.action).to eq UserHistoryAction::RATE
            expect(UserHistory.last.value).to eq '6'
          end
        end

        context 'rated it with two values' do
          before do
            UserHistory.add user, anime, UserHistoryAction::RATE, 6, prior_rate
            UserHistory.add user, anime, UserHistoryAction::RATE, 7, 6
          end
          it do
            expect(UserHistory.last.prior_value).to eq '0'
          end
        end
      end

      context 'watched episode' do
        subject { UserHistory.add user, anime, UserHistoryAction::EPISODES, 1 }
        it do
          expect { subject }.to change(UserHistory, :count).by 1
          expect(UserHistory.last.action).to eq UserHistoryAction::EPISODES
          expect(UserHistory.last.value).to eq '1'
          expect(UserHistory.last.prior_value).to eq '0'
        end
      end

      context 'watched episode and' do
        let(:prior_episode) { 1 }
        before do
          UserHistory.add user, anime, UserHistoryAction::EPISODES, prior_episode
        end

        context 'watched 0 episode' do
          subject { UserHistory.add user, anime, UserHistoryAction::EPISODES, 0, prior_episode }
          it do
            expect { subject }.to change(UserHistory, :count).by(-1)
          end
        end

        context 'watched the same episode again' do
          subject { UserHistory.add user, anime, UserHistoryAction::EPISODES, 1, prior_episode }
          it do
            expect { subject }.to_not change UserHistory, :count
          end
        end

        context 'watched next episode' do
          subject { UserHistory.add user, anime, UserHistoryAction::EPISODES, 2, prior_episode }
          it do
            expect { subject }.to_not change UserHistory, :count
            expect(UserHistory.last.action).to eq UserHistoryAction::EPISODES
            expect(UserHistory.last.value).to eq '1,2'
          end
        end

        context 'watched more next episodes' do
          before do
            UserHistory.add user, anime, UserHistoryAction::EPISODES, 2, prior_episode
            UserHistory.last.update value: 1.upto(88).map { |v| v }.join(',')
          end
          subject { UserHistory.add user, anime, UserHistoryAction::EPISODES, 89, 88 }

          it do
            expect { subject }.to change(UserHistory, :count).by 1
            expect(UserHistory.last.action).to eq UserHistoryAction::EPISODES
            expect(UserHistory.last.value).to eq '89'
          end
        end

        context 'watched episode from another anime' do
          subject { UserHistory.add user, anime_2, UserHistoryAction::EPISODES, 1, 0 }
          it do
            expect { subject }.to change(UserHistory, :count).by 1
          end
        end

        context 'watched episode from another anime and watched next episode from first anime' do
          subject do
            UserHistory.add user, anime_2, UserHistoryAction::EPISODES, 1, 0
            UserHistory.add user, anime, UserHistoryAction::EPISODES, 2, prior_episode
          end
          it do
            expect { subject }.to change(UserHistory, :count).by 1
          end
        end

        context 'watched next episode and watched previous episode again' do
          subject do
            UserHistory.add user, anime, UserHistoryAction::EPISODES, 2, prior_episode
            UserHistory.add user, anime, UserHistoryAction::EPISODES, prior_episode, 2
          end
          it do
            expect { subject }.to_not change UserHistory, :count
            expect(UserHistory.last.action).to eq UserHistoryAction::EPISODES
            expect(UserHistory.last.value).to eq '1'
          end
        end

        context 'watched next 2 episodes and watched one episode back' do
          subject do
            UserHistory.add user, anime, UserHistoryAction::EPISODES, 3, prior_episode
            UserHistory.add user, anime, UserHistoryAction::EPISODES, 2, 3
          end
          it do
            expect { subject }.to_not change UserHistory, :count
            expect(UserHistory.last.action).to eq UserHistoryAction::EPISODES
            expect(UserHistory.last.value).to eq '1,2'
          end
        end

        context 'after UserHistory::EPISODE_BACKWARD_CHECK_INTERVAL watched 0 episode' do
          before do
            touch UserHistory.last, UserHistory::EPISODE_BACKWARD_CHECK_INTERVAL.ago - 1.minute
          end
          subject { UserHistory.add user, anime, UserHistoryAction::EPISODES, 0, prior_episode }

          it do
            expect { subject }.to change(UserHistory, :count).by 1
            expect(UserHistory.last.action).to eq UserHistoryAction::EPISODES
            expect(UserHistory.last.value).to eq '0'
          end
        end

        context 'after UserHistory::EPISODE_BACKWARD_CHECK_INTERVAL watched 2 episode' do
          before do
            touch UserHistory.last, UserHistory::EPISODE_BACKWARD_CHECK_INTERVAL.ago - 1.minute
          end
          subject { UserHistory.add user, anime, UserHistoryAction::EPISODES, 2, prior_episode }

          it do
            expect { subject }.to change(UserHistory, :count).by 1
            expect(UserHistory.last.action).to eq(UserHistoryAction::EPISODES)
            expect(UserHistory.last.value).to eq('2')
          end
        end

        context 'after UserHistory::EPISODE_BACKWARD_CHECK_INTERVAL watched 2 episode and watched 0 episode' do
          before do
            touch UserHistory.last, UserHistory::EPISODE_BACKWARD_CHECK_INTERVAL.ago - 1.minute
          end
          subject do
            UserHistory.add user, anime, UserHistoryAction::EPISODES, 2, prior_episode
            UserHistory.add user, anime, UserHistoryAction::EPISODES, 0, 2
          end

          it do
            expect { subject }.to change(UserHistory, :count).by 1
            expect(UserHistory.last.action).to eq UserHistoryAction::EPISODES
            expect(UserHistory.last.value).to eq '0'
          end
        end

        context 'after UserHistory::EpisodeBackwaldCheckInterval watched 0 episode and then watched 3 episode' do
          before do
            touch UserHistory.last, UserHistory::EPISODE_BACKWARD_CHECK_INTERVAL.ago - 1.minute
          end
          subject do
            UserHistory.add user, anime, UserHistoryAction::EPISODES, 0, prior_episode
            UserHistory.add user, anime, UserHistoryAction::EPISODES, 3, 0
          end

          it do
            expect { subject }.to change(UserHistory, :count).by 1
            expect(UserHistory.last.action).to eq UserHistoryAction::EPISODES
            expect(UserHistory.last.value).to eq '0,3'
          end
        end
      end

      context 'watched 7 episodes and after UserHistory::EPISODE_BACKWARD_CHECK_INTERVAL watched 6 episode and 7 episode' do
        subject do
          UserHistory.add user, anime, UserHistoryAction::EPISODES, 7
          touch UserHistory.last, UserHistory::EPISODE_BACKWARD_CHECK_INTERVAL.ago - 1.minute

          UserHistory.add user, anime, UserHistoryAction::EPISODES, 6, 7
          UserHistory.add user, anime, UserHistoryAction::EPISODES, 7, 6
        end
        it do
          expect { subject }.to change(UserHistory, :count).by 1
          expect(UserHistory.last.value).to eq '7'
        end
      end

      context "merges :completed and #{UserHistoryAction::RATE} into #{UserHistoryAction::COMPLETE_WITH_SCORE}" do
        subject do
          UserHistory.add user, anime, UserHistoryAction::STATUS, UserRate.statuses[:completed]
          UserHistory.add user, anime, UserHistoryAction::RATE, 5
        end
        it do
          expect { subject }.to change(UserHistory, :count).by 1

          last = UserHistory.last
          expect(last.action).to eq UserHistoryAction::COMPLETE_WITH_SCORE
          expect(last.value).to eq '5'
        end
      end

      context "merges :completed and #{UserHistoryAction::RATE} into #{UserHistoryAction::COMPLETE_WITH_SCORE} only for the same anime" do
        subject do
          UserHistory.add user, anime_2, UserHistoryAction::STATUS, UserRate.statuses[:completed]
          UserHistory.add user, anime, UserHistoryAction::RATE, 5
        end
        it do
          expect { subject }.to change(UserHistory, :count).by 2
        end
      end

      context "merges #{UserHistoryAction::RATE} and :completed into #{UserHistoryAction::COMPLETE_WITH_SCORE}" do
        subject do
          UserHistory.add user, anime, UserHistoryAction::RATE, 5
          UserHistory.add user, anime, UserHistoryAction::STATUS, UserRate.statuses[:completed]
        end
        it do
          expect { subject }.to change(UserHistory, :count).by 1

          last = UserHistory.last
          expect(last.action).to eq UserHistoryAction::COMPLETE_WITH_SCORE
          expect(last.value).to eq '5'
        end
      end
    end
  end

  describe 'permissions' do
    let(:user_history) { build_stubbed :user_history, user: user }
    subject { Ability.new user }

    context 'owner' do
      let(:user) { build_stubbed :user, :user }
      it { is_expected.to be_able_to :destroy, user_history }
    end

    context 'guest' do
      let(:user) { nil }
      it { is_expected.to_not be_able_to :destroy, user_history }
    end

    context 'user' do
      let(:user) { build_stubbed :user, :user }
      let(:user_2) { build_stubbed :user }
      let(:user_history) { build_stubbed :user_history, user: user_2 }

      it { is_expected.to_not be_able_to :destroy, user_history }
    end
  end
end
