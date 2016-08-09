class JsExports::Topics < JsExports::Base
  include Singleton

  def placeholder entry
    entry.id.to_s
  end

  def sweep html
  end

  def export user
  end
end
