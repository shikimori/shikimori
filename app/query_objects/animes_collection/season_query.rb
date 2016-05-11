class AnimesCollection::SeasonQuery < AnimesCollection::PageQuery
  OVA_KEY = 'OVA/ONA'

  def page
    1
  end

  def pages_count
    1
  end

private

  def process query
    query.group_by do |v|
      v.anime? && (v.kind_ova? || v.kind_ona?) ? OVA_KEY : v.kind.to_s
    end
  end
end
