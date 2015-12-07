class CopyrightedIds
  include Singleton

  MARKER = 'z'
  CONFIG_PATH = Rails.root.join 'config/copyrighted_ids.yml'

  def change id, type
    if ids[type.to_sym] && ids[type.to_sym].include?(id.to_s)
      change "#{MARKER}#{id}", type
    else
      id
    end
  end

  def restore id, type
    cleaned_id = id.to_s.gsub(/-.*$/, '')

    if ids[type.to_sym] && ids[type.to_sym].include?(cleaned_id)
      fail CopyrightedResource, copyrighted_resource(type, cleaned_id)
    else
      cleaned_id.gsub(/^#{MARKER}+/, '').to_i
    end
  end

private

  def copyrighted_resource type, id
     type.to_s.capitalize.constantize.find(id)
  end

  def ids
    @ids ||= yaml.each_with_object({}) do |(type, ids), memo|
      memo[type] = Set.new ids.map(&:to_s)
    end
  end

  def yaml
    YAML.load_file(CONFIG_PATH)
  end
end
