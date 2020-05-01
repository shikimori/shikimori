# frozen_string_literal: true

class Viewing::BulkCreate
  method_object %i[user! viewed_klass! viewed_ids!]

  def call
    bulk_create_viewings
    read_notifiactions
  end

  private

  def viewing_klass
    @viewing_klass ||= (viewed_klass.name + 'Viewing').constantize
  end

  def bulk_create_viewings
    batch = new_viewed_ids.map do |id|
      viewing_klass.new(user_id: user.id, viewed_id: id)
    end
    viewing_klass.import batch
  rescue ActiveRecord::RecordNotUnique
    # do nothing
  end

  def new_viewed_ids
    @new_viewed_ids ||= all_viewed_ids - existing_viewed_ids
  end

  def all_viewed_ids
    viewed_klass.where(id: viewed_ids).pluck(:id)
  end

  def existing_viewed_ids
    viewing_klass
      .where(user_id: user.id, viewed_id: all_viewed_ids)
      .pluck(:viewed_id)
  end

  def read_notifiactions
    Message.where(
      read: false,
      to_id: user.id,
      kind: MessageType::QUOTED_BY_USER,
      linked_id: new_viewed_ids,
      linked_type: viewed_klass.name
    ).update_all(read: true)

    user.touch
  end
end
