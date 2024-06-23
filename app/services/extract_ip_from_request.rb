class ExtractIpFromRequest
  method_object :request

  def call
    (
      request.env['HTTP_X_FORWARDED_FOR'].presence ||
        request.env['HTTP_X_REAL_IP'].presence ||
        request.env['REMOTE_ADDR'].presence ||
        request.remote_ip
    )&.split(',')&.first
  end
end
