class Animes::SortField
  pattr_initialize :default, :view_context

  delegate :ru_content?, :current_user, to: :view_context

  def field
    if order == 'russian' || order == 'name'
      localized_name_field
    else
      order || default
    end
  end

private

  def order
    view_context.params[:order]
  end

  def localized_name_field
    if ru_content? && russian_names?
      'russian'
    else
      'name'
    end
  end

  def russian_names?
    !current_user ||
      (current_user.russian? && current_user.preferences.russian_names?)
  end
end
