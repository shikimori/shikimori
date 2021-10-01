# patch to silence Faye EventMachine ssl errors
# until LetsEncrypt SSL 2020-09-30 problem is fixed
module HttpStubConnectionFix
  def ssl_verify_peer cert_string
    true
  end

  def ssl_handshake_completed
    true
  end
end

EventMachine::HttpStubConnection.send :prepend, HttpStubConnectionFix
