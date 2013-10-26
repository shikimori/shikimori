module MangasHelper
  def truncate_publisher(name)
    name.size > 18 ? name.gsub(/ Magazine$| Comics$| Collection$/i, '') : name
  end
end
