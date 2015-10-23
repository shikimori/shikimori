class TopicDecorator < BaseDecorator
  instance_cache :comments

  # имя топика
  # def display_title
    # if !preview?
      # user.nickname
    # elsif generated_news? || object.class == AniMangaComment
      # h.localized_name object.linked
    # elsif contest? || object.respond_to?(:title)
      # object.title
    # else
      # object.name
    # end
  # end

  # картинка топика(аватарка автора)
  # def avatar
    # if special? && linked.respond_to?(:image) && !(news? && !generated? && !preview?)
      # ImageUrlGenerator.instance.url linked, :x48
    # elsif special? && linked.respond_to?(:logo)
      # ImageUrlGenerator.instance.url linked, :x48
    # elsif review?
      # ImageUrlGenerator.instance.url linked.target, :x48
    # else
      # user.avatar_url(48)
    # end
  # end

  # def avatar2x
    # if special? && linked.respond_to?(:image) && !(news? && !generated? && !preview?)
      # ImageUrlGenerator.instance.url linked, :x96
    # elsif special? && linked.respond_to?(:logo)
      # ImageUrlGenerator.instance.url linked, :x96
    # elsif review?
      # ImageUrlGenerator.instance.url linked.target, :x96
    # else
      # user.avatar_url(80)
    # end
  # end

  # надо ли свёртывать длинный контент топика?
  def should_shorten?
    !news? || (news? && generated?) || (news? && object.body !~ /\[wall\]/)
  end

  # показывать ли тело топика?
  def show_body?
    preview? || !generated? || contest? || review?
  end

  # показывать ли автора в header блоке
  def show_author_in_header?
    !generated_news?
  end

  # показывать ли автора в footer блоке
  def show_author_in_footer?
    preview? && (news? || review?) && (!show_author_in_header? || avatar != user.avatar_url(48))
  end

  # тег топика
  def tag
    return nil if linked.nil? || review? || contest?

    if linked.kind_of? Review
      h.localized_name linked.target
    else
      h.localized_name linked if linked.respond_to?(:name) && linked.respond_to?(:russian)
    end
  end

  # переключение на отображение отзывов
  #def reviews_only!
    #@force_reviews = true
  #end

  #def reviews_only?
    #!!@force_reviews
  #end

  # переключение на отображение в режиме превью
  def preview_mode!
    @preview_mode = true
  end
  def topic_mode!
    @preview_mode = false
  end
  def preview?
    @preview_mode.nil? ? h.params[:action] != 'show' : @preview_mode
  end
end
