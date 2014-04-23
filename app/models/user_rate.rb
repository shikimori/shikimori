# аниме и манга в списке пользователя
# TODO: переделать status в enumerize (https://github.com/brainspec/enumerize)
class UserRate < ActiveRecord::Base
  # максимальное значение эпизодов/частей
  MAXIMUM_VALUE = 2000

  belongs_to :target, polymorphic: true
  belongs_to :anime, class_name: Anime.name, foreign_key: :target_id
  belongs_to :manga, class_name: Manga.name, foreign_key: :target_id

  belongs_to :user, touch: true

  before_save :smart_process_changes
  before_save :check_data

  #['episodes', 'chapters', 'volumes'].each do |counter|
    #define_method("update_#{counter}") do |value|
      #value = value.to_i
      #prior_value = self.send(counter)

      #return if value >= MAXIMUM_VALUE

      #if value > self.target.send(counter) && self.target.send(counter) != 0
        #self.send("#{counter}=", self.target.send(counter))
      #elsif value < 0
        #self.send("#{counter}=", 0)
      #else
        #self.send("#{counter}=", value)
      #end

      #if ['chapters', 'volumes'].include?(counter)
        #anoter_counter = counter == 'chapters' ? 'volumes' : 'chapters'
        #self.send("#{anoter_counter}=", self.target.send(anoter_counter)) if self.send(counter) == self.target.send(counter) && value != prior_value
        #self.send("#{anoter_counter}=", 0) if self.send(counter) == 0 && value != prior_value
      #end

      #self.status = UserRateStatus.get(UserRateStatus::Completed) if self.send(counter) == self.target.send(counter) &&
                                                                     #UserRateStatus.get(self.status) != UserRateStatus::Completed

      #self.status = UserRateStatus.get(UserRateStatus::Watching) if prior_value == 0 &&
                                                                    #self.send(counter) > 0 &&
                                                                    #UserRateStatus.get(self.status) == UserRateStatus::Planned

      #self.status = UserRateStatus.get(UserRateStatus::Planned) if prior_value > 0 &&
                                                                  #self.send(counter) == 0# &&
                                                                  ##UserRateStatus.get(self.status) == UserRateStatus::Watching

      #UserHistory.add(self.user_id, self.target, UserHistoryAction.const_get(counter.capitalize), self.send(counter), prior_value) if self.save
    #end
  #end

  def update_score(value)
    value = value.to_i
    value = 10 if value > 10
    value = 0 if value < 0

    prior_score = self.score
    self.score = value

    UserHistory.add(self.user_id, self.target, UserHistoryAction::Rate, self.score, prior_score) if self.save
  end

  def smart_process_changes
    status_updated if changes['status']
    counter_updated 'episodes' if changes['episodes'] && anime?
    counter_updated 'chapters' if changes['chapters'] && manga?
    counter_updated 'volumes' if changes['volumes'] && manga?
  end

  def status_updated
    self.episodes = target.episodes if anime? && completed?
    self.volumes = target.volumes if manga? && completed?
    self.chapters = target.chapters if manga? && completed?

    UserHistory.add user_id, target, UserHistoryAction::Status, status, changes['status'].first
  end

  def counter_updated counter
    self[counter] = target[counter] if self[counter] > target[counter] && !target[counter].zero?
    self[counter] = changes[counter].first if self[counter] > MAXIMUM_VALUE
    self[counter] = 0 if self[counter] < 0

    #value = self[counter].to_i
    #prior_value = self.send(counter)

    #return if value >= MAXIMUM_VALUE

    #if value > self.target.send(counter) && self.target.send(counter) != 0
      #self.send("#{counter}=", self.target.send(counter))
    #elsif value < 0
      #self.send("#{counter}=", 0)
    #else
      #self.send("#{counter}=", value)
    #end

    #if ['chapters', 'volumes'].include?(counter)
      #anoter_counter = counter == 'chapters' ? 'volumes' : 'chapters'
      #self.send("#{anoter_counter}=", self.target.send(anoter_counter)) if self.send(counter) == self.target.send(counter) && value != prior_value
      #self.send("#{anoter_counter}=", 0) if self.send(counter) == 0 && value != prior_value
    #end

    #self.status = UserRateStatus.get(UserRateStatus::Completed) if self.send(counter) == self.target.send(counter) &&
                                                                    #UserRateStatus.get(self.status) != UserRateStatus::Completed

    #self.status = UserRateStatus.get(UserRateStatus::Watching) if prior_value == 0 &&
                                                                  #self.send(counter) > 0 &&
                                                                  #UserRateStatus.get(self.status) == UserRateStatus::Planned

    #self.status = UserRateStatus.get(UserRateStatus::Planned) if prior_value > 0 &&
                                                                #self.send(counter) == 0# &&
                                                                ##UserRateStatus.get(self.status) == UserRateStatus::Watching

    #UserHistory.add(self.user_id, self.target, UserHistoryAction.const_get(counter.capitalize), self.send(counter), prior_value) if self.save
  end

  def check_data
    if target.nil?
      self.errors[:target] = 'не задано аниме или манга'
      return false
    end
    if target.respond_to?(:episodes) && self.target.episodes < (self.episodes || 0) && self.target.episodes != 0
      self.errors[:episodes] = 'некорректное число эпизодов'
      return false
    end
    if target.respond_to?(:volumes) && self.target.volumes < (self.volumes || 0) && self.target.volumes != 0
      self.errors[:volumes] = 'некорректное число томов'
      return false
    end
    if target.respond_to?(:chapters) && self.target.chapters < (self.chapters || 0) && self.target.chapters != 0
      self.errors[:chapters] = 'некорректное число глав'
      return false
    end
    unless UserRateStatus.contains(status)
      self.errors[:status] = 'некорректный статус'
      return false
    end
  end

  def anime?
    target_type == 'Anime'
  end

  def manga?
    target_type == 'Manga'
  end

  def planned?
    status == UserRateStatus.get(UserRateStatus::Planned)
  end

  def watching?
    status == UserRateStatus.get(UserRateStatus::Watching)
  end

  def completed?
    status == UserRateStatus.get(UserRateStatus::Completed)
  end

  def on_hold?
    status == UserRateStatus.get(UserRateStatus::OnHold)
  end

  def dropped?
    status == UserRateStatus.get(UserRateStatus::Dropped)
  end

  def notice_html
    notice.present? ? BbCodeFormatter.instance.format_comment(notice) : notice
  end
end
