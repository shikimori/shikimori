require Rails.root.join('lib', 'rake_tasks')

class SubtitlesJob < Struct.new(:options)
  def perform
    Proxy.preload
    if options.include? :ongoing
      SubtitlesTasks.new.ongoing
    else
      SubtitlesTasks.new.latest
    end
  end
end
