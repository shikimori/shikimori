class Contest::CleanupSuggestions
  method_object :contest

  CONFIG_PATH = 'config/app/cleanup_suggestions.yml'

  delegate :suggestions, to: :@contest

  def call
    # Rails.logger.info "Contest::CleanupSuggestions #{@contest.id}"

    suggestions
      .joins(:user)
      .merge(User.suspicious)
      .destroy_all

    if @contest.character?
      suggestions
        .joins('left join characters on contest_suggestions.item_id = characters.id')
        .where(characters: { name: config[:names] })
        .destroy_all
    end
  end

private

  def config
    @config ||= YAML.load_file(Rails.root.join(CONFIG_PATH))
  end
end
