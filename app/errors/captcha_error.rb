class CaptchaError < StandardError
  def initialize url
    super "captcha when trying to open \"#{url}\""
  end
end
