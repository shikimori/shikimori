class BbCodes::ContestStatusTag
  include Singleton
  include Translation

  REGEXP = /
    \[
      contest_status=(?<id>\d+)
    \]
  /xi

  def format text
    text.gsub REGEXP do |matched|
      contest = Contest.find_by id: $~[:id]

      if contest
        url = url_generator.contest_url contest

        ru = Types::Locale[:ru]
        en = Types::Locale[:en]

        contest = "<span class='translated' "\
          "data-text-ru='#{Contest.model_name.human(ru)}' "\
          "data-text-en='#{Contest.model_name.human(en)}' "\
          "></span>"
        link = "<a href='#{url}' class='b-link translated' "\
          "data-text-ru='#{contest.title_ru}' "\
          "data-text-en='#{contest.title_en}' "\
          "></a>"
        finished = "<span class='translated' "\
          "data-text-ru='#{i18n_t('finished', locale: ru)} "\
          "data-text-en='#{i18n_t('finished', locale: en)} "\
          "></span>"

        "#{contest} #{link} #{finished}"
      else
        matched
      end
    end
  end

private

  def url_generator
    UrlGenerator.instance
  end
end
