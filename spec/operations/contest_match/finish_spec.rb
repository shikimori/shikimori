describe ContestMatch::Finish do
  include_context :timecop

  subject(:call) { ContestMatch::Finish.call contest_match }

  let(:contest_match) do
    create :contest_match, :freezed,
      started_on: Time.zone.yesterday,
      finished_on: Time.zone.yesterday,
      left_id:,
      left_type:,
      right_id:,
      right_type:,
      cached_votes_up:,
      cached_votes_down:
  end

  let(:left_id) { anime_1.id }
  let(:left_type) { Anime.name }
  let(:right_id) { anime_2.id }
  let(:right_type) { Anime.name }

  let(:anime_1) { create :anime }
  let(:anime_2) { create :anime }

  let(:cached_votes_up) { 0 }
  let(:cached_votes_down) { 0 }

  describe 'vote' do
    before { allow(contest_match.round.contest).to receive(:swiss?).and_return is_swiss }
    let(:is_swiss) { false }

    subject! { call }

    it { expect(contest_match).to be_finished }

    context 'no right variant' do
      let(:right_id) { nil }
      it { expect(contest_match.winner_id).to eq left_id }
    end

    context 'left_votes > right_votes' do
      let(:cached_votes_up) { 1 }
      it { expect(contest_match.winner_id).to eq left_id }
    end

    context 'right_votes > left_votes' do
      let(:cached_votes_down) { 1 }
      it { expect(contest_match.winner_id).to eq right_id }
    end

    context 'left_votes == right_votes' do
      let(:cached_votes_up) { 1 }
      let(:cached_votes_down) { 1 }

      context 'swiss strategy' do
        let(:is_swiss) { true }
        it { expect(contest_match.winner_id).to be_nil }
      end

      context 'not swiss strategy' do
        let(:is_swiss) { false }

        context 'left.score > right.score' do
          let(:anime_1) { create :anime, score: 9 }
          let(:anime_2) { create :anime, score: 5 }

          it { expect(contest_match.winner_id).to eq left_id }
        end

        context 'right.score < left.score' do
          let(:anime_1) { create :anime, score: 5 }
          let(:anime_2) { create :anime, score: 9 }

          it { expect(contest_match.winner_id).to eq right_id }
        end

        context 'left.score == right.score' do
          let(:anime_1) { create :anime, score: 5 }
          let(:anime_2) { create :anime, score: 5 }

          it { expect(contest_match.winner_id).to eq left_id }
        end
      end
    end
  end

  describe 'cleanup suspicious votes' do
    before { contest_match.disliked_by user }
    subject! { call }

    context 'normal user' do
      let(:user) { seed :user_admin }
      it do
        expect(contest_match).to be_finished
        expect(contest_match.winner_id).to eq right_id
      end
    end

    context 'suspicious user' do
      let(:user) { create :user, :suspicious }
      it do
        expect(contest_match).to be_finished
        expect(contest_match.winner_id).to eq left_id
      end
    end
  end
end
