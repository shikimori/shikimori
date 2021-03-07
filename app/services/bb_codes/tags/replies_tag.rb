class BbCodes::Tags::RepliesTag
  include Singleton
  include Translation

  REGEXP = /
    (?<tag>
      (?<brs> \n* ) # group name used in reply service
      \[
        replies=(?<ids> [\d,]+ )
      \]
    )
  /mx
  DISPLAY_LIMIT = 100

  RU = Types::Locale[:ru]
  EN = Types::Locale[:en]

  def format text
    text.gsub REGEXP do |_match|
      ids = comment_ids Regexp.last_match[:ids].split(',')
      replies = ids.map { |id| "[comment=#{id}][/comment]" }.join(', ')

      next unless ids.any?

      single_class = ids.one? ? 'single' : nil

      "<div class='b-replies translated-before #{single_class}' "\
        "data-text-ru='#{i18n_t('replies', locale: RU)}' "\
        "data-text-en='#{i18n_t('replies', locale: EN)}' "\
        "data-text-alt-ru='#{i18n_t('reply', locale: RU)}' "\
        "data-text-alt-en='#{i18n_t('reply', locale: EN)}' "\
        ">#{replies}</div>"
    end
  end

  private

  def comment_ids ids
    Comment
      .where(id: ids)
      .order(:id)
      .limit(DISPLAY_LIMIT)
      .pluck(:id)
  end
end
