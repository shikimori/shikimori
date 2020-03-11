module VersionedConcern
  extend ActiveSupport::Concern

  VERSIONS_PER_PAGE = 20

  def parameterized_versions
    versions_scope
      .paginate([h.params[:page].to_i, 1].max, VERSIONS_PER_PAGE)
      .transform(&:decorate)
  end

private

  def versions_scope
    scope = VersionsQuery.by_item(object)
    scope = scope.by_field(h.params[:field]) if h.params[:field]
    scope
  end
end
