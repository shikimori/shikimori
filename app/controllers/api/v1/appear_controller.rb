class Api::V1::AppearController < Api::V1Controller
  before_action :authenticate_user!

  api :POST, '/appears', 'Mark comments or topics as read'
  param :ids, :undef
  def create
    return head 200 unless params[:ids]

    type_ids.each do |type, ids|
      klass = type.gsub('entry', 'topic').titleize.constantize

      Viewing::BulkCreate.call(
        user: current_user,
        viewed_klass: klass,
        viewed_ids: ids
      )
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
end
