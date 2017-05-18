class RanobeSerializer < MangaSerializer
  def url
    UrlGenerator.instance.ranobe_path object
  end
end
