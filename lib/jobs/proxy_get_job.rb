class ProxyGetJob
  def perform
    ProxyParser.new.import
  end
end
