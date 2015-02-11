class ForumView
  include Draper::ViewHelpers
  prepend ActiveCacher.instance

  pattr_initialize :resource
  instance_cache :section, :linked, :new_topic_section

  def new_topic_url
    h.new_topic_url section, linked, 'topic[user_id]' => h.current_user.id,
      'topic[section_id]' => new_topic_section.id,
      'topic[linked_id]' => linked ? linked.id : nil, 'topic[linked_type]' => linked ? linked.class.name : nil
  end

  def section
    if h.params[:section]
      Section.find_by_permalink(h.params[:section])
    else
      resource.section
    end
  end

  def linked
    case section.permalink
      when 'a' then Anime.find h.params[:linked]
      when 'm' then Manga.find h.params[:linked]
      when 'c' then Character.find h.params[:linked]
      when 'g' then Group.find h.params[:linked]
      when 'reviews' then Review.find h.params[:linked]
      else nil
    end if h.params[:linked]
  end

private
  def new_topic_section
    if section.id
      section
    elsif section.permalink == 'news'
      Section.find_by_permalink('a')
    else
      section.id ? section : Section.find_by_permalink('o')
    end
  end
end
