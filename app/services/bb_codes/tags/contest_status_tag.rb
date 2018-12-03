class BbCodes::Tags::ContestStatusTag
  include Singleton
  include Translation

  REGEXP = /
    \[
      contest_status=(?<id>\d+)
      \s
      (?<status>started|finished)
    \]
  /mix

  def format text
    text.gsub REGEXP do |match|
      contest = Contest.find_by id: Regexp.last_match[:id]

      if contest
        "#{contest_text} #{link_text contest} #{finished_text Regexp.last_match[:status]}."
      else
        match
      end
    end
  end

private

  def contest_text
    "<span class='translated-after' "\
      "data-text-ru='#{Contest.model_name.human(locale: Types::Locale[:ru])}' "\
      "data-text-en='#{Contest.model_name.human(locale: Types::Locale[:en])}' "\
      '></span>'
  end

  def link_text contest
    "<a href='#{url contest}' class='b-link translated-after' "\
      "data-text-ru='#{contest.title_ru}' "\
      "data-text-en='#{contest.title_en}' "\
      '></a>'
  end

  def finished_text status
    "<span class='translated-after' "\
      "data-text-ru='#{i18n_t(status, locale: Types::Locale[:ru])}' "\
      "data-text-en='#{i18n_t(status, locale: Types::Locale[:en])}' "\
      '></span>'
  end

  def url contest
    UrlGenerator.instance.contest_url contest
  end
end
