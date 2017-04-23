class BbCodes::ContestRoundStatusTag
  include Singleton
  include Translation

  REGEXP = /
    \[
      contest_round_status=(?<id>\d+)
    \]
  /xi

  def format text
    text.gsub REGEXP do |match|
      round = ContestRound.find_by id: $~[:id]

      if round
        url = url_generator.round_contest_url(round.contest, round)

        ru = Types::Locale[:ru]
        en = Types::Locale[:en]

        link_text = "<a href='#{url}' class='b-link translated-after' "\
          "data-text-ru='#{round.title_ru}' "\
          "data-text-en='#{round.title_en}' "\
          "></a>"
        finished_text = "<span class='translated-after' "\
          "data-text-ru='#{i18n_t('finished', locale: ru)}' "\
          "data-text-en='#{i18n_t('finished', locale: en)}' "\
          "></span>"

        "#{link_text} #{finished_text}"
      else
        match
      end
    end
  end

  private

  def url_generator
    UrlGenerator.instance
  end
end
