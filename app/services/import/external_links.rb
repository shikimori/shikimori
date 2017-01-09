class Import::ExternalLinks
  method_object :target, :external_links

  def call
    ExternalLink.import build_external_links
  end

private

  def cleanup
    ExternalLink.where(src_id: @target.id).delete_all
  end

  def build_external_links
    new_external_links.map do |external_link|
      ExternalLink.new(
        entry: @target,
        source: external_link[:source],
        url: external_link[:url]
      )
    end
  end

  def new_external_links
    @external_links.select do |external_link|
      @target.external_links.none? { |v| v.source == external_link[:source] }
    end
  end
end
