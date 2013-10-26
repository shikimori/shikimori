class SiteScoresJob
  def perform
    SiteScoresService.new.calculate
  end
end
