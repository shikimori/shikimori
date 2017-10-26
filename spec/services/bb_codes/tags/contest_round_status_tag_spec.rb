describe BbCodes::Tags::ContestRoundStatusTag do
  let(:tag) { BbCodes::Tags::ContestRoundStatusTag.instance }

  describe '#format' do
    subject { tag.format text }

    let(:text) { "[contest_round_status=#{round.id}]" }
    let(:round) { create :contest_round, :finished }
    let(:round_url) { UrlGenerator.instance.round_contest_url round.contest, round }

    it do
      is_expected.to eq(
        "<a href='#{round_url}' class='b-link translated-after' "\
          "data-text-ru='#{round.title_ru}' "\
          "data-text-en='#{round.title_en}' ></a> "\
          "<span class='translated-after' "\
          "data-text-ru='завершён' "\
          "data-text-en='has finished' ></span>."
      )
    end
  end
end
