class VersionedView < ViewObjectBase
  include VersionedConcern

  pattr_initialize :object
end
