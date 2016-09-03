class Api::V1::AppearController < Api::V1::ApiController
  before_filter :authenticate_user!

  # пометка элементов прочитанными
  api :POST, '/appear', 'Mark comments or topics as read'
  param :ids, :undef
  def create
    return head 200 unless params[:ids]

    type_ids.each do |type, ids|
      klass = type.gsub('entry', 'topic').titleize.constantize
      bulk_create_viewings.(current_user, klass, ids)
    end

    head 200
  end

  private

  def type_ids
    params[:ids]
      .split(',')
      .each_with_object({}) do |v, memo|
        data = v.split('-')
        (memo[data[0]] ||= []) << data[1].to_i
      end
  end

  def bulk_create_viewings
    Viewing::BulkCreate.new
  end
end
