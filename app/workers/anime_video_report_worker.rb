class AnimeVideoReportWorker < SiteParserWithCache
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform id
    report = AnimeVideoReport.find id
    return unless report.pending?

    if report.broken?
      if video_broken?(report.anime_video)
        report.accept!(approver)
      elsif report.user_id == User::GuestID && (report.doubles.zero? || report.doubles(:rejected) > 0)
        report.reject!(approver)
      end

    elsif report.uploaded?
      report.accept!(approver) if AnimeOnline::Uploaders.trusted?(report.user_id)
    end

    report
  end

private
  def approver
    BotsService.get_poster
  end

  def video_broken? video
    case video.hosting
      when 'vk.com' then is_vk_broken(video)
      when 'sibnet.ru' then is_sibnet_broken(video)
    end
  end

  def is_vk_broken video
    doc = Nokogiri::HTML get(video.url)
    [
      "\n\nЭто видео изъято из публичного доступа.\n\n", "\n\nThis video has been removed from public access.\n\n",
      "\n\nДанная видеозапись скрыта настройками приватности и недоступна для просмотра.\n\n", "\n\nThis video is protected by privacy settings.\n\n"
    ].include? doc.css('#page_wrap div').first.try(:text)
  end

  def is_sibnet_broken video
    doc = Nokogiri::HTML get(video.url)
    ["Ошибка обработки видео", "Îøèáêà îáðàáîòêè âèäåî"].include? doc.css('.videostatus').try(:text)
  end
end
