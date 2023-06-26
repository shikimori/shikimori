module VersionedConcern
  extend ActiveSupport::Concern

  VERSIONS_PER_PAGE = 20

  def parameterized_versions
    versions_scope
      .paginate(h.page, VERSIONS_PER_PAGE)
      .lazy_map(&:decorate)
  end

private

  def versions_scope
    scope = VersionsQuery.by_item(object, h.params[:field])
    scope = scope.by_field(h.params[:field]) if h.params[:field]
    scope
  end
end
