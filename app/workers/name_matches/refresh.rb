class NameMatches::Refresh
  include Sidekiq::Worker
  sidekiq_options queue: :cpu_intensive

  def perform type, ids = nil
    query(type, ids).find_in_batches(batch_size: 1000) do |entries|
      NameMatch.transaction { replace entries, type }
    end
  end

private

  def replace entries, type
    NameMatch.where(target_type: type, target_id: entries.map(&:id)).delete_all
    NameMatch.import build_matches(entries)
  end

  def build_matches entries
    entries.flat_map do |entry|
      puts "building matches for #{entry.to_param}" unless Rails.env.test?
      NameMatches::BuildMatches.call(entry)
    end
  end

  def query type, ids
    if ids.present?
      type.constantize.where(id: ids)
    else
      type.constantize
    end
  end
end
