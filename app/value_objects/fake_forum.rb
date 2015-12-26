class FakeForum
  vattr_initialize :id, :name

  def permalink
    id
  end

  def to_param
    id
  end
end
