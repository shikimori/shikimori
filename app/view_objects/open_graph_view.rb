class OpenGraphView < ViewObjectBase
  attr_reader :page_title
  attr_writer :description, :canonical_url
  attr_accessor :type, :image, :image_type,
    :image_width,
    :image_height,
    :twitter_card,
    :video_duration, :video_release_date, :video_tags,
    :book_release_date, :book_tags,
    :notice,
    :keywords, :noindex, :nofollow

  PAGE_TITLE_SEPARATOR = ' / '

  def site_name
    Shikimori::NAME_RU
  end

  def canonical_url
    return @canonical_url if @canonical_url.present?

    url =
      if h.params[:page].present? && h.params[:page].to_s.match?(/^\d+$/)
        h.current_url(page: nil)
      else
        h.request.url
      end

    url.gsub(/\?.*/, '')
  end

  def page_title= value
    @page_title ||= []
    @page_title.push HTMLEntities.new.decode(value)
  end

  def headline allow_not_set = false
    @page_title&.last || (
      allow_not_set ? site_name : raise('open_graph.page_title is not set')
    )
  end

  def description
    @description || @notice
  end

  def meta_title
    <<~TITLE.strip.delete("\n")
      #{'[DEV] ' if Rails.env.development?}
      #{(@page_title || [site_name]).reverse.join PAGE_TITLE_SEPARATOR}
      #{(PAGE_TITLE_SEPARATOR + 'EN') unless I18n.russian?}
      #{(PAGE_TITLE_SEPARATOR + h.current_user.id.to_s) if h.user_signed_in? && !I18n.russian?}
    TITLE
  end

  def meta_robots
    # return if canonical_url != h.request.url

    content = [
      ('noindex' if noindex),
      ('nofollow' if nofollow)
    ].compact

    content.join ',' if content.any?
  end
end
