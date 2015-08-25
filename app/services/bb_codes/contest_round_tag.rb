class BbCodes::ContestRoundTag
  include Singleton
  include Translation

  REGEXP = /
    \[
      contest_round=(?<id>\d+)
    \]
  /xi

  def format text
    text.gsub REGEXP do |matched|
      round = ContestRound.find_by id: $~[:id]

      if round
        url = url_generator.round_contest_url round.contest, round
        "<a href='#{url}' class='b-link'>#{round.title}</a> #{i18n_t 'finished'}."
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
