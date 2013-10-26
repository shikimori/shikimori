class TestJob < Struct.new(:text, :emails)
  def perform
    Xmpp.message "message from test job"
  end
end
