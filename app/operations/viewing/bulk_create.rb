# frozen_string_literal: true

class Viewing::BulkCreate
  prepend ActiveCacher.instance
  instance_cache :viewing_klass, :new_viewed_ids

  attr_reader :user, :viewed_klass, :viewed_ids

  def call user, viewed_klass, viewed_ids
    @user = user
    @viewed_klass = viewed_klass
    @viewed_ids = viewed_ids

    bulk_create_viewings
    update_messages_as_read
  end

  private

  def viewing_klass
    (viewed_klass.name + 'Viewing').constantize
  end

  def bulk_create_viewings
    batch = new_viewed_ids.map do |id|
      viewing_klass.new(user_id: user.id, viewed_id: id)
    end
    viewing_klass(viewed_klass).import batch
  rescue ActiveRecord::RecordNotUnique
    # do nothing
  end

  def new_viewed_ids
    all_viewed_ids - existing_viewed_ids
  end

  def all_viewed_ids
    viewed_klass.where(id: viewed_ids).pluck(:id)
  end

  def existing_viewed_ids
    viewing_klass
      .where(user_id: user.id, viewed_id: all_viewed_ids)
      .pluck(:viewed_id)
  end

  # update messages in user inbox as read
  def update_messages_as_read
    Message.where(
      read: false,
      to_id: user.id,
      kind: MessageType::QuotedByUser,
      linked_id: new_viewed_ids,
      linked_type: viewed_klass.name
    ).update_all(read: true)
  end
end
