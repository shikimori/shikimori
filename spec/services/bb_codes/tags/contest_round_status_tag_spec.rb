describe BbCodes::Tags::ContestRoundStatusTag do
  let(:tag) { BbCodes::Tags::ContestRoundStatusTag.instance }

  subject { tag.format text }

  let(:text) { "[contest_round_status=#{round.id} #{status}]" }
  let(:round) { create :contest_round }
  let(:round_url) { UrlGenerator.instance.round_contest_url round.contest, round }

  describe 'finished' do
    let(:status) { :finished }
    it do
      is_expected.to eq(
        "<a href='#{round_url}' class='b-link translated-after' "\
          "data-text-ru='#{round.title_ru}' "\
          "data-text-en='#{round.title_en}' ></a> "\
          "<span class='translated-after' "\
          "data-text-ru='завершён' "\
          "data-text-en='finished' ></span>."
      )
    end
  end

  describe 'started' do
    let(:status) { :started }
    it do
      is_expected.to eq(
        "<a href='#{round_url}' class='b-link translated-after' "\
          "data-text-ru='#{round.title_ru}' "\
          "data-text-en='#{round.title_en}' ></a> "\
          "<span class='translated-after' "\
          "data-text-ru='начат' "\
          "data-text-en='started' ></span>."
      )
    end
  end
end
