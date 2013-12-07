class Forbidden < StatusCodeError
  def status
    :forbidden
  end
end
