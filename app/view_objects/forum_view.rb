class ForumView < Draper::Decorator
  prepend ActiveCacher.instance

  instance_cache :section, :linked, :new_topic_section

  def initialize
  end

  def new_topic_url
    h.new_topic_url new_topic_section, linked, 'topic[user_id]' => h.current_user.id,
      'topic[section_id]' => new_topic_section.id,
      'topic[type]' => section.permalink == 'news' ? 'AnimeNews' : 'Topic',
      'topic[linked_id]' => linked ? linked.id : nil, 'topic[linked_type]' => linked ? linked.class.name : nil
  end

  def section
    Section.find_by_permalink h.params[:section]
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
    section.id ? section : Section.find_by_permalink('o')
  end
end
