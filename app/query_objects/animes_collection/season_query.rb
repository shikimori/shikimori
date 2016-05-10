class AnimesCollection::SeasonQuery < AnimesCollection::PageQuery
  OVA_KEY = 'OVA/ONA'

private

  def collection
    super.group_by do |v|
      v.anime? && (v.kind_ova? || v.kind_ona?) ? OVA_KEY : v.kind.to_s
    end
  end
end
