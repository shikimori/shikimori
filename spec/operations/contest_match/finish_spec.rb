describe ContestMatch::Finish do
  include_context :seeds
  include_context :timecop

  let(:operation) { ContestMatch::Finish.new contest_match }

  let(:contest_match) do
    create :contest_match,
      :started,
      started_on: Time.zone.yesterday,
      finished_on: Time.zone.yesterday,
      left_id: left_id,
      left_type: left_type,
      right_id: right_id,
      right_type: right_type
  end
  let(:left_id) { anime_1.id }
  let(:left_type) { Anime.name }
  let(:right_id) { anime_2.id }
  let(:right_type) { Anime.name }

  let(:anime_1) { create :anime }
  let(:anime_2) { create :anime }

  let!(:user_vote) { nil }

  subject! { operation.call }

  it do
    expect(contest_match).to be_finished
  end

  describe '#obtain_winner_id' do
    context 'no right variant' do
      let(:right_id) { nil }
      it { expect(contest_match.winner_id).to eq left_id }
    end

    context 'left_votes > right_votes' do
      let!(:user_vote) do
        create :contest_user_vote,
          match: contest_match,
          user_id: user.id,
          ip: '1',
          item_id: left_id
      end

      it { expect(contest_match.winner_id).to eq left_id }
    end

    context 'right_votes > left_votes' do
      let!(:user_vote) do
        create :contest_user_vote,
          match: contest_match,
          user_id: user.id,
          ip: '1',
          item_id: right_id
      end

      it { expect(contest_match.winner_id).to eq right_id }
    end

    context 'left_votes == right_votes' do
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
