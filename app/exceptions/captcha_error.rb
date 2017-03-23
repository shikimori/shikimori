class CaptchaError < Exception
  def initialize url
    super "captcha when trying to open \"#{url}\""
  end
end
