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
        "#{Contest.model_name.human} <a href='#{url}' class='b-link'>#{contest.name}</a> #{i18n_t 'finished'}."
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
