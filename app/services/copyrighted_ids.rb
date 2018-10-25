class CopyrightedIds
  include Singleton

  MARKERS =
    if Rails.env.test?
      %w[z a]
    else
      %w[z y x w v u t s r q p o n m l k j i h g f e d c b a]
    end

  CONFIG_PATH = "#{Rails.root}/config/app/copyrighted_ids.yml"
  TEST_IDS = %w[
    9999999
    8888888 z8888888
    7777777 z7777777 a7777777
    6666666 z6666666 a6666666 zz6666666
    5555555 z5555555 a5555555 zz5555555 az5555555
  ]

  def change id, type
    type = type.to_sym
    id = id.to_s

    return id unless ids[type]&.include?(id)

    MARKERS.size.times do |index|
      new_id = "#{MARKERS[index]}#{id}"
      return new_id unless ids[type].include?(new_id)
    end

    change "#{MARKERS[0]}#{id}", type
  end

  def restore id, type
    cleaned_id = id.to_s.gsub(/-.*$/, '')

    if ids[type.to_sym]&.include?(cleaned_id)
      raise CopyrightedResource, copyrighted_resource(type, cleaned_id)
    else
      restore_id cleaned_id
    end
  end

  def restore_id id
    id.gsub(/^(?:#{MARKERS.join('|')})+/, '').to_i
  end

private

  def copyrighted_resource type, id
    type.to_s.capitalize.constantize.find restore_id(id)
  end

  def ids
    @ids ||= yaml.each_with_object({}) do |(type, ids), memo|
      memo[type] = Set.new(Rails.env.test? ? TEST_IDS : ids.map(&:to_s))
    end
  end

  def yaml
    YAML.load_file(CONFIG_PATH)
  end
end
