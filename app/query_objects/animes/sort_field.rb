class Animes::SortField
  pattr_initialize :default, :view_context

  delegate :ru_domain?, :current_user, to: :view_context

  def field
    if localized_name_field?
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
    if ru_domain? && russian_names?
      'russian'
    else
      'name'
    end
  end

  def localized_name_field?
    order == 'russian' || order == 'name' ||
      (order.nil? && (default == 'russian' || default == 'name'))
  end

  def russian_names?
    !current_user ||
      (current_user.russian? && current_user.preferences.russian_names?)
  end
end
