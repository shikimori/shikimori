class JsExports::Base
  def self.inherited klass
    klass.const_set 'PLACEHOLDERS', /
      data-track_#{klass.name.gsub(/.*:/, '').underscore}="(\d+)"
    /mix
  end

  def placeholder entry
    entry.id.to_s
  end

  def sweep html
    cleanup
    html.scan(PLACEHOLDERS) do |results|
      track results[0].to_i
    end
  end
end
