# сервис через который должны создаваться/изменяться/удаляться все объекты,
# отображаемые на форуме и имеющие realtime обновления
class FayeService
  pattr_initialize :actor, :publisher_faye_id

  def create trackable
    was_persisted = trackable.persisted?

    if trackable.save
      publisher.publish trackable, was_persisted ? :updated : :created
      true
    else
      false
    end
  end

  def create! trackable
    was_persisted = trackable.persisted?

    trackable.save!
    publisher.publish trackable, was_persisted ? :updated : :created
  end

  def update trackable, params
    if trackable.update params
      publisher.publish trackable, :updated
      true
    else
      false
    end
  end

  def destroy trackable
    case trackable
      when Message
        trackable.delete_by @actor

      when Critique
        publisher.publish trackable.topic(trackable.locale), :deleted
        trackable.destroy

      else
        publisher.publish trackable, :deleted
        trackable.destroy
    end
  end

  def offtopic comment, is_offtopic
    ids = comment.mark_offtopic is_offtopic
    publisher.publish_marks ids, 'offtopic', is_offtopic
    ids
  end

  def convert_review forum_entry, is_convert_to_review
    new_entry =
      if is_convert_to_review && forum_entry.is_a?(Comment)
        Comment::ConvertToReview.call forum_entry
      elsif !is_convert_to_review && forum_entry.is_a?(Review)
        Review::ConvertToComment.call forum_entry
      end

    publisher.publish_conversion forum_entry, new_entry if new_entry
    new_entry
  end

  def set_replies comment # rubocop:disable AccessorMethodName
    replies_text =
      if comment.body =~ BbCodes::Tags::RepliesTag::REGEXP
        $LAST_MATCH_INFO[:tag]
      else
        ''
      end
    replies_html = BbCodes::Text.call replies_text

    publisher.publish_replies comment, replies_html
  end

private

  def publisher
    FayePublisher.new @actor, @publisher_faye_id
  end
end
