class FakeForum
  vattr_initialize :id, :name_ru, :name_en

  def permalink
    id
  end

  def to_param
    id
  end

  def name
    I18n.russian? ? name_ru : name_en
  end
end
