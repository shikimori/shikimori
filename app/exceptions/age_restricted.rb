class AgeRestricted < StatusCodeError
  def status
    :forbidden
  end
end
