class MessageDecorator < BaseDecorator
  instance_cache :action_tag

  def image
    anime_related? ? anime.image.url(:x48) : from.avatar_url(48)
  end

  def image_2x
    anime_related? ? anime.image.url(:x96) : from.avatar_url(80)
  end

  def url
    if kind == MessageType::Episode
      linked.linked.decorate.url
    elsif kind == MessageType::ContestFinished
      h.contest_url linked
    elsif MessagesQuery::NEWS_KINDS.include?(kind)
      UrlGenerator.instance.topic_url linked
    else
      h.profile_url from
    end
  end

  def title
    anime_related? ? h.localized_name(anime) : from.nickname
  end

  def generated_news?
    linked.respond_to?(:generated_news?) && linked.generated_news?
  end

  def action_tag
    OpenStruct.new(
      type: linked.action,
      text: linked.action == 'episode' ?
        "#{linked.action_text} #{linked.value}" :
        linked.action_text
    ) if generated_news?
  end

  def generate_body
    case kind
      when MessageType::VersionAccepted
        BbCodeFormatter.instance.format_comment i18n_t('version_accepted',
          version_id: linked.id,
          item_type: linked.item_type.underscore,
          item_id: linked.item_id
        )

      when MessageType::VersionRejected
        if object.body.present?
          BbCodeFormatter.instance.format_comment i18n_t('version_rejected_with_reason',
            version_id: linked.id,
            item_type: linked.item_type.underscore,
            item_id: linked.item_id,
            moderator: linked.moderator.nickname,
            reason: object.body
          )
        else
          BbCodeFormatter.instance.format_comment i18n_t('version_rejected',
            version_id: linked.id,
            item_type: linked.item_type.underscore,
            item_id: linked.item_id
          )
        end

      when MessageType::ContestFinished
        BbCodeFormatter.instance.format_comment "[contest_status=#{linked_id}]"

      else
        h.get_message_body(object).html_safe
    end
  end

private

  def anime_related?
    MessageType::ANIME_RELATED.include? kind
  end

  def anime
    linked.linked
  end
end
