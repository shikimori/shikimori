describe BbCodes::ContestRoundStatusTag do
  let(:tag) { BbCodes::ContestRoundStatusTag.instance }

  describe '#format' do
    subject { tag.format text }

    let(:text) { "[contest_round_status=#{round.id}]" }
    let(:round) { create :contest_round, :finished }
    let(:round_url) { UrlGenerator.instance.round_contest_url round.contest, round }

    it { is_expected.to eq "<a href='#{round_url}' class='b-link'>#{round.title}</a> завершён." }
  end
end
