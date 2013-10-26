class ToshokanJob
  def perform
    TokyoToshokanParser.grab_ongoings
  end
end
