describe BbCodes::Tags::ContestStatusTag do
  let(:tag) { BbCodes::Tags::ContestStatusTag.instance }

  describe '#format' do
    subject { tag.format text }

    let(:text) { "[contest_status=#{contest.id}]" }
    let(:contest) { create :contest, :finished }
    let(:contest_url) { UrlGenerator.instance.contest_url contest }

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
          "data-text-en='has finished' ></span>."
      )
    end
  end
end
