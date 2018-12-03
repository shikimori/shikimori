class BbCodes::Tags::ContestRoundStatusTag
  include Singleton
  include Translation

  REGEXP = /
    \[
      contest_round_status=(?<id>\d+)
      \s
      (?<status>started|finished)
    \]
  /mix

  def format text
    text.gsub REGEXP do |match|
      round = ContestRound.find_by id: Regexp.last_match[:id]

      if round
        "#{link_text round} #{finished_text Regexp.last_match[:status]}."
      else
        match
      end
    end
  end

private

  def link_text round
    "<a href='#{url round}' class='b-link translated-after' "\
      "data-text-ru='#{round.title_ru}' "\
      "data-text-en='#{round.title_en}' "\
      '></a>'
  end

  def finished_text status
    "<span class='translated-after' "\
      "data-text-ru='#{i18n_t(status, locale: Types::Locale[:ru])}' "\
      "data-text-en='#{i18n_t(status, locale: Types::Locale[:en])}' "\
      '></span>'
  end

  def url round
    UrlGenerator.instance.round_contest_url round.contest, round
  end
end
