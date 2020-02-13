class Animes::Query < QueryObjectBase
  def self.fetch klass:, params:, user:
    new(klass.all)
      .kind(params[:kind] || params[:type])
  end

  def kind value
    return self if value.blank?

    chain Animes::Filters::Kind.call(@scope, value)
  end
end
