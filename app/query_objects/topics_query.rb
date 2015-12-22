class TopicsQuery < ChainableQueryBase
  # pattr_initialize :forum, :user, :linked
  pattr_initialize :user

  def initialize user
    @user = user
    @relation = prepare_query

    @relation = except_hentai @relation
  end

  def by_forum forum
    case forum && forum.permalink
      when nil
        if @user
          where(
            "type != ? or (type = ? and #{Entry.table_name}.id in (?))",
              GroupComment.name, GroupComment.name, user_subscription_ids
          )
        else
          where_not type: GroupComment.name
        end

      when 'reviews'
        where forum_id: forum.id
        order! created_at: :desc

      when Forum.static[:news].permalink
        where type: [AnimeNews.name, MangaNews.name, CosplayComment.name]

      else
        where forum_id: forum.id
    end

    except_generated forum

    self
  end

  def by_linked linked
    return self unless linked
    where linked: linked
    self
  end

  def as_views is_preview, is_mini
    result.map do |topic|
      Topics::Factory.new(is_preview, is_mini).build topic
    end
  end

private

  def prepare_query
    Entry
      .with_viewed(@user)
      .includes(:forum, :user)
      .order_default
  end

  def except_generated forum
    @relation = if forum && forum.permalink == 'news'
      @relation.wo_episodes
    else
      @relation.wo_empty_generated
    end
  end

  def except_hentai query
    query
      .joins("left join animes on animes.id=linked_id and linked_type='Anime'")
      .where('animes.id is null or animes.censored=false')
  end

  def user_subscription_ids
    Subscription
      .where(user_id: user.id, target_type: Entry::Types)
      .pluck(:target_id)
  end
end
