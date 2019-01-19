class Tags::CoubConfig
  CONFIG_PATH = 'config/app/coub_tags.yml'

  def ignored_tags
    @ignored_tags ||= custom_ignored_tags + auto_ignored_tags
  end

  def custom_ignored_tags
    config[:custom_ignored_tags]
  end

  def auto_ignored_tags
    config[:auto_ignored_tags]
  end

  def added_tags
    config[:added_tags]
  end

private

  def config
    @config ||= YAML.load_file(Rails.root.join(CONFIG_PATH))
  end
end
