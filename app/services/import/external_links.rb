class Import::ExternalLinks
  method_object :target, :external_links

  def call
    # I purposely do not use "ExternalLink.import" here.
    # "ExternalLink.create!" should fail with exception when
    # unknown "source" is encountered
    new_external_links.each do |external_link|
      ExternalLink.create!(
        entry: @target,
        source: external_link[:source],
        url: external_link[:url]
      )
    end
  end

private

  def new_external_links
    @external_links.select do |external_link|
      @target.external_links.none? { |v| v.source == external_link[:source] }
    end
  end
end
