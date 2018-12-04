describe BbCodes::Tags::ContestStatusTag do
  let(:tag) { BbCodes::Tags::ContestStatusTag.instance }

  subject { tag.format text }

  let(:text) { "[contest_status=#{contest.id} #{status}]" }
  let(:contest) { create :contest }
  let(:contest_url) { UrlGenerator.instance.contest_url contest }

  context 'finished' do
    let(:status) { :finished }
    it do
      is_expected.to eq(
        "<span class='translated-after' "\
          "data-text-ru='Турнир' "\
          "data-text-en='Contest' ></span> "\
          "<a href='#{contest_url}' "\
          "class='b-link translated-after' "\
          "data-text-ru='#{contest.title_ru}' "\
          "data-text-en='#{contest.title_en}' ></a> "\
          "<span class='translated-after' "\
          "data-text-ru='завершён' "\
          "data-text-en='finished' ></span>."
      )
    end
  end

  context 'started' do
    let(:status) { :started }
    it do
      is_expected.to eq(
        "<span class='translated-after' "\
          "data-text-ru='Турнир' "\
          "data-text-en='Contest' ></span> "\
          "<a href='#{contest_url}' "\
          "class='b-link translated-after' "\
          "data-text-ru='#{contest.title_ru}' "\
          "data-text-en='#{contest.title_en}' ></a> "\
          "<span class='translated-after' "\
          "data-text-ru='начат' "\
          "data-text-en='started' ></span>."
      )
    end
  end
end
