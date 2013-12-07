class Unauthorized < StatusCodeError
  def status
    :unauthorized
  end
end
