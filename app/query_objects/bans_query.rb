class BansQuery < QueryObjectBase
private
  def query
    Ban.order(id: :desc).includes(comment: :user)
  end
end
