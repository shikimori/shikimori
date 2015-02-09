class EpisodeNotification < ActiveRecord::Base
  belongs_to :anime

  boolean_attribute :subtitles
  boolean_attribute :fandub
end
