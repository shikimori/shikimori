class Titles::KindTitle
  include Translation
  vattr_initialize :kind, :klass

  def text
    kind.to_s
  end

  def url_params
    { kind: text }
  end

  def title
    klass.kind.options.find { |_title, kind| kind == text }.first
  end
end
