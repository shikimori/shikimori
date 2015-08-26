describe BbCodes::ContestStatusTag do
  let(:tag) { BbCodes::ContestStatusTag.instance }

  describe '#format' do
    subject { tag.format text }

    let(:text) { "[contest_status=#{contest.id}]" }
    let(:contest) { create :contest, :finished }
    let(:contest_url) { UrlGenerator.instance.contest_url contest }

    it { is_expected.to eq "Опрос <a href='#{contest_url}' class='b-link'>#{contest.name}</a> завершён." }
  end
end
