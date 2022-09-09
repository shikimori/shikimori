# сервис через который должны создаваться/изменяться/удаляться все объекты,
# отображаемые на форуме и имеющие realtime обновления
class FayeService
  vattr_initialize :actor, :publisher_faye_id

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
    return false unless trackable.update params

    case trackable
      when Review
        publisher.publish trackable.maybe_topic, :updated
      else
        publisher.publish trackable, :updated
    end

    true
  end

  def destroy trackable
    case trackable
      when Message
        trackable.delete_by @actor

      when Critique
        publisher.publish trackable.topic, :deleted
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
        Comment::ConvertToReview.call comment: forum_entry, actor: @actor
      elsif !is_convert_to_review && forum_entry.is_a?(Topic)
        Review::ConvertToComment.call forum_entry.linked
      end

    if new_entry
      publisher.publish_conversion(
        is_convert_to_review ? :comment : :review,
        forum_entry,
        new_entry
      )
    end

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
