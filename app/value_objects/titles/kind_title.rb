class Titles::KindTitle
  include Translation
  pattr_initialize :kind, :klass

  def text
    kind.to_s
  end

  def url_params
    { type: text }
  end

  def title
    klass.kind.options.find { |title, kind| kind == text }.first
  end
end
