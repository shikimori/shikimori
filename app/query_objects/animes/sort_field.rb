class Animes::SortField
  pattr_initialize :default, :view_context

  delegate :russian_names?, to: :view_context

  def field
    if localized_name_field?
      russian_names? ? 'russian' : 'name'
    else
      order || default
    end
  end

private

  def order
    view_context.params[:order]
  end

  def localized_name_field?
    order == 'russian' || order == 'name' ||
      (order.nil? && (default == 'russian' || default == 'name'))
  end
end
