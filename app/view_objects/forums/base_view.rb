class Forums::BaseView < ViewObjectBase
  attr_implement :section
  # pattr_initialize :resource
  # instance_cache :section, :linked, :new_topic_section

  # def new_topic_url
    # h.new_topic_url section, linked, 'topic[user_id]' => h.current_user.id,
      # 'topic[section_id]' => new_topic_section.id,
      # 'topic[linked_id]' => linked ? linked.id : nil, 'topic[linked_type]' => linked ? linked.class.name : nil
  # end

  # def section
    # if h.params[:section]
      # Section.find_by_permalink(h.params[:section])
    # elsif resource
      # resource.section
    # else
      # Section.static[:all]
    # end
  # end

  def linked
    case section.permalink
      when 'a'
        id = CopyrightedIds.instance.restore h.params[:linked], 'anime'
        Anime.find id

      when 'm'
        id = CopyrightedIds.instance.restore h.params[:linked], 'manga'
        Manga.find id

      when 'c'
        id = CopyrightedIds.instance.restore h.params[:linked], 'character'
        Character.find id

      when 'g'
        Group.find h.params[:linked].to_i

      when 'reviews'
        Review.find h.params[:linked]

      else
        nil

    end if h.params[:linked]
  end

  # def add_postloader?
  # end

  # def next_page_url
  # end

  # def next_page_url
  # end

# private

  # def new_topic_section
    # if section.id
      # section
    # elsif section.permalink == 'news'
      # Section.find_by_permalink('a')
    # else
      # section.id ? section : Section.find_by_permalink('o')
    # end
  # end
end
