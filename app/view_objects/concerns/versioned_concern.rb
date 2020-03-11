module VersionedConcern
  extend ActiveSupport::Concern

  def parameterized_versions
    versions_scope
      .paginate([h.params[:page].to_i, 1].max, 20)
      .transform(&:decorate)
  end

private

  def versions_scope
    scope = VersionsQuery.by_item(object)
    scope = scope.by_field(h.params[:field]) if h.params[:field]
    scope
  end
end
