describe ContestMatch::Start do
  include_context :timecop

  let(:operation) { ContestMatch::Start.new contest_match }

  let(:contest_match) do
    create :contest_match,
      :created,
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

  describe do
    subject! { operation.call }
    it { expect(contest_match).to be_started }
  end

  context 'no right member' do
    let(:right_id) { nil }
    subject! { operation.call }

    it do
      expect(contest_match).to be_started
      expect(contest_match).to have_attributes(
        left_type: left_type,
        left_id: left_id,
        right_type: nil,
        right_id: nil
      )
    end
  end

  context 'no left member' do
    let(:left_id) { nil }
    subject! { operation.call }

    it do
      expect(contest_match).to be_started
      expect(contest_match).to have_attributes(
        left_type: right_type,
        left_id: right_id,
        right_type: nil,
        right_id: nil
      )
    end
  end

  describe '#reset_user_vote_key' do
    %i[can_vote_1 can_vote_2 can_vote_3].each do |user_vote_key|
      context user_vote_key do
        before do
          contest_match.round.contest.update user_vote_key: user_vote_key
          contest_match.reload

          create_list :user, 2

          allow(contest_match.round.contest).to receive(:started?).and_return true
        end

        subject! { operation.call }

        it do
          User.find_each do |user|
            expect(user.can_vote? contest_match.round.contest).to eq true
          end
        end
      end
    end
  end
end
