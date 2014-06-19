class AppearController < ApplicationController
  before_filter :authenticate_user!

  # пометка элементов прочитанными
  def read
    type_ids = (params[:ids] || '').split(',').inject({}) do |rez,v|
      data = v.split('-')
      (rez[data[0]] ||= []) << data[1].to_i
      rez
    end

    type_ids.each do |type,ids|
      klass = type.titleize.constantize
      klass_id_key = (klass.name.downcase + '_id').to_sym
      klass_view = (klass.name + 'View').constantize

      # прочтённые сущности
      existed_ids = klass.where(id: ids).select(:id).map(&:id)

      # записи о прочтении прочтённых сущностей
      existed_views = klass_view.where(user_id: current_user.id, klass_id_key => existed_ids)
        .select(klass_id_key)
        .map { |v| v[klass_id_key] }

      # прочтённые сущности, о которых ещё нет записи о прочтении
      new_ids = existed_ids.select { |id| !existed_views.include?(id) }

      batch = new_ids.map do |id|
        klass_view.new(user_id: current_user.id, klass_id_key => id)
      end
      klass_view.import batch

      # уведомления о прочтении в почте пользователя
      Message.where(
        read: false,
        to_id: current_user.id,
        kind: MessageType::QuotedByUser,
        linked_id: new_ids,
        linked_type: klass.name
      ).update_all(read: true)
    end

    render json: {}
  rescue ActiveRecord::RecordNotUnique
    render json: {}
  end
end
