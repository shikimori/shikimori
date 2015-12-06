class CopyrightedIds
  include Singleton

  CONFIG_PATH = Rails.root.join 'config/copyrighted_ids.yml'

  def change id, type
    if ids[type.to_sym] && ids[type.to_sym].include?(id.to_s)
      change "z#{id}", type
    else
      id
    end
  end

  def restore id, type
    cleaned_id = id.to_s.gsub(/-.*$/, '')

    if ids[type.to_sym] && ids[type.to_sym].include?(cleaned_id)
      nil
    else
      cleaned_id.gsub(/^z+/, '').to_i
    end
  end

private

  def ids
    @ids ||= yaml.each_with_object({}) do |(type, ids), memo|
      memo[type] = Set.new ids.map(&:to_s)
    end
  end

  def yaml
    YAML.load_file(CONFIG_PATH)
  end
end
