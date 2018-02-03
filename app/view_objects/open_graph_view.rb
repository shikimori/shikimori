class OpenGraphView < ViewObjectBase
  prepend ActiveCacher.instance
  # instance_cache :styles, :hot_topics, :moderation_policy

  vattr_initialize %i[page_title noindex nofollow keywords description]

  def site_name
    h.ru_host? ? Shikimori::NAME_RU : Shikimori::NAME_EN
  end

  def canonical_url # rubocop:disable AbcSize
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
    @page_title.push HTMLEntities.new.decode(title)
  end

  def h1
    @page_title&.last || raise('page_title is not set')
  end

  # def noindex
  #   @meta_noindex = true
  # end

  # def nofollow
  #   @meta_nofollow = true
  # end

  # def description text
  #   @meta_description = text
  # end

  # def keywords text
  #   @meta_keywords = text
  # end
end
