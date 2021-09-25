class JsExports::ExportBase
  attr_implement :fetch_entries
  attr_implement :serialize

  def self.inherited klass
    name = klass.name
      .gsub(/.*:/, '')
      .underscore.gsub('_export', '')
      .singularize

    klass.include Singleton
    klass.const_set 'PLACEHOLDER', /data-track_#{name}="(\d+)"/mix

    super
  end

  def placeholder topic
    topic.id.to_s
  end

  def sweep html
    cleanup
    html.scan(self.class::PLACEHOLDER) do |results|
      track results[0].to_i
    end
  end

  def export user
    return [] if tracked_ids.none?

    fetch_entries(user).map { |topic| serialize topic, user }
  end

private

  def track id
    tracked_ids << id
  end

  def cleanup
    Thread.current[self.class.name] = []
  end

  def tracked_ids
    Thread.current[self.class.name] ||= []
  end
end
