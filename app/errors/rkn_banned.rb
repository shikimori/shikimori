class RknBanned < StatusCodeError
  def status
    :forbidden
  end
end
