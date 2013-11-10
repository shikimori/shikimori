class FindAnimeJob < Struct.new(:pages, :full_import)
  def perform
    FindAnimeImporter.new.import 0..pages, full_import
  end
end
