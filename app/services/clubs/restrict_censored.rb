class Clubs::RestrictCensored
  method_object %i[club! current_user]

  def call
    raise ActiveRecord::RecordNotFound if !@current_user && @club.censored?
  end
end
