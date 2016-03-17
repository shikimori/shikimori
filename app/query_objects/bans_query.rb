class BansQuery < SimpleQueryBase
private
  def query
    Ban.order(id: :desc).includes(comment: :user)
  end
end
