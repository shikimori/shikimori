class BbCodes::Tags::ContestStatusTag
  include Singleton
  include Translation

  REGEXP = /
    \[
      contest_status=(?<id>\d+)
    \]
  /xi

  def format text
    text.gsub REGEXP do |match|
      contest = Contest.find_by(id: Regexp.last_match[:id])

      if contest
        url = url_generator.contest_url(contest)

        ru = Types::Locale[:ru]
        en = Types::Locale[:en]

        contest_text = "<span class='translated-after' "\
          "data-text-ru='#{Contest.model_name.human(locale: ru)}' "\
          "data-text-en='#{Contest.model_name.human(locale: en)}' "\
          "></span>"
        link_text = "<a href='#{url}' class='b-link translated-after' "\
          "data-text-ru='#{contest.title_ru}' "\
          "data-text-en='#{contest.title_en}' "\
          "></a>"
        finished_text = "<span class='translated-after' "\
          "data-text-ru='#{i18n_t('finished', locale: ru)}' "\
          "data-text-en='#{i18n_t('finished', locale: en)}' "\
          "></span>"

        "#{contest_text} #{link_text} #{finished_text}."
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
