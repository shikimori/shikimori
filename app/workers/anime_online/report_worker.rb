class AnimeOnline::ReportWorker < SiteParserWithCache
  include Sidekiq::Worker
  sidekiq_options retry: false

  VK_BROKEN_TEXTS = [
    /\n\nЭто видео изъято из публичного доступа.\n\n/i,
    /\n\nThis video has been removed from public access.\n\n/i,
    /\n\nДанная видеозапись скрыта настройками приватности и недоступна для просмотра.\n\n/i,
    /\n\nThis video is protected by privacy settings.\n\n/i,
    /\n\nВидеозапись была помечена модераторами сайта как «Материал для взрослых»./i,
    /\n\nThis video was marked as Adult.Embedding adult videos is not allowed by VK.\n\n/i
  ]
  SIBNET_BROKEN_TEXTS = ["Ошибка обработки видео", "Îøèáêà îáðàáîòêè âèäåî"]

  def perform id
    report = AnimeVideoReport.find id
    return unless report.pending?

    if report.broken?
      if video_broken?(report.anime_video)
        report.accept!(approver)
      elsif AnimeOnline::Activists.can_trust?(report.user_id, report.anime_video.hosting)
        report.accept!(approver)
      elsif report.user_id == User::GuestID && (report.doubles.zero? || report.doubles(:rejected) > 0)
        report.reject!(approver)
      end

    elsif report.uploaded?
      report.accept!(approver) if AnimeOnline::Uploaders.trusted?(report.user_id)
    end

    report
  end

  def video_broken? video
    case video.hosting
      when 'vk.com' then vk_broken?(video)
      when 'sibnet.ru' then sibnet_broken?(video)
    end
  end

private

  def approver
    BotsService.get_poster
  end

  def vk_broken? video
    doc = Nokogiri::HTML get(video.url)
    text = doc.css('#page_wrap div').first.try(:text)
    VK_BROKEN_TEXTS.any? {|v| text =~ v }
  end

  def sibnet_broken? video
    doc = Nokogiri::HTML get(video.url)
    SIBNET_BROKEN_TEXTS.include? doc.css('.videostatus').try(:text)
  end

  def get url
    Retryable.retryable tries: 2, on: [Errno::ECONNRESET], sleep: 1 do
      open(url, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE).read.fix_encoding
    end
  end
end
