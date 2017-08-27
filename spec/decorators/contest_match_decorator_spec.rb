describe ContestMatchDecorator do
  let :contest_match do
    build_stubbed :contest_match, state,
      left: left_anime,
      right: right_anime,
      cached_votes_up: 3,
      cached_votes_down: 6,
      winner_id: left_anime.id
  end

  let(:left_anime) { build_stubbed :anime }
  let(:right_anime) { build_stubbed :anime }
  let(:state) { :created }

  let(:decorator) { contest_match.decorate }

  describe '#left' do
    it { expect(decorator.left).to eq left_anime }
  end

  describe '#right' do
    it { expect(decorator.right).to eq right_anime }
  end

  describe '#left_percent' do
    it { expect(decorator.left_percent).to eq 33.3 }
  end

  describe '#right_percent' do
    it { expect(decorator.right_percent).to eq 66.6 }
  end

  describe '#status' do
    subject { decorator.status member_id }
    let(:member_id) { left_anime.id }

    context 'created' do
      let(:state) { :created }
      it { is_expected.to eq :created }
    end

    context 'started' do
      let(:state) { :started }
      it { is_expected.to eq :started }
    end

    context 'finished' do
      let(:state) { :finished }

      context 'member is winner' do
        let(:member_id) { left_anime.id }
        it { is_expected.to eq :winner }
      end

      context 'member is not winner' do
        let(:member_id) { right_anime.id }
        it { is_expected.to eq :loser }
      end
    end
  end
end
