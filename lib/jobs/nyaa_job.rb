class NyaaJob
  def perform
    NyaaParser.grab_ongoings
  end
end
