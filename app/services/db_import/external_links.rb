class DbImport::ExternalLinks
  method_object :target, :external_links

  def call
    ExternalLink.transaction do
      cleanup
      import
    end
  end

private

  def cleanup
    ExternalLink
      .where(source: :myanimelist)
      .where(entry: @target)
      .delete_all
  end

  def import
    # I purposely do not use "ExternalLink.import" here.
    # "ExternalLink.create!" should fail with exception when
    # unknown "source" is encountered
    new_external_links
      .uniq { |external_link| external_link[:url] }
      .each do |external_link|
        ExternalLink.create!(
          entry: @target,
          source: :myanimelist,
          kind: external_link[:kind],
          url: external_link[:url]
        ) rescue ActiveRecord::RecordInvalid
      end
  end

  def new_external_links
    @external_links.select do |external_link|
      @target.all_external_links.none? { |v| v.source == external_link[:source] }
    end
  end
end
