class BbCodes::BroadcastTag
  include Singleton

  REGEXP = /
    (\n|<br>)?
    \[broadcast\]
  /mix

  def format text
    text.gsub(REGEXP, '\1').strip
  end
end
