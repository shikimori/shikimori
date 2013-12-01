# аниме и манга в списке пользователя
# TODO: переделать status в enumerize (https://github.com/brainspec/enumerize)
class UserRate < ActiveRecord::Base
  # максимальное значение эпизодов/частей
  MaximumNumber = 2000

  belongs_to :target, polymorphic: true
  belongs_to :anime, class_name: Anime.name, foreign_key: :target_id
  belongs_to :manga, class_name: Manga.name, foreign_key: :target_id

  belongs_to :user, touch: true

  before_save :check_data

  def update_status(value)
    prior_status = self.status
    self.status = value
    self.episodes = self.target.episodes if self.target.respond_to?(:episodes) && self.status == UserRateStatus.get(UserRateStatus::Completed)
    self.volumes = self.target.volumes if self.target.respond_to?(:volumes) && self.status == UserRateStatus.get(UserRateStatus::Completed)
    self.chapters = self.target.chapters if self.target.respond_to?(:chapters) && self.status == UserRateStatus.get(UserRateStatus::Completed)

    UserHistory.add(self.user_id, self.target, UserHistoryAction::Status, self.status, prior_status) if self.save
  end

  ['episodes', 'chapters', 'volumes'].each do |counter|
    define_method("update_#{counter}") do |value|
      value = value.to_i
      prior_value = self.send(counter)

      return if value >= MaximumNumber

      if value > self.target.send(counter) && self.target.send(counter) != 0
        self.send("#{counter}=", self.target.send(counter))
      elsif value < 0
        self.send("#{counter}=", 0)
      else
        self.send("#{counter}=", value)
      end

      if ['chapters', 'volumes'].include?(counter)
        anoter_counter = counter == 'chapters' ? 'volumes' : 'chapters'
        self.send("#{anoter_counter}=", self.target.send(anoter_counter)) if self.send(counter) == self.target.send(counter) && value != prior_value
        self.send("#{anoter_counter}=", 0) if self.send(counter) == 0 && value != prior_value
      end

      self.status = UserRateStatus.get(UserRateStatus::Completed) if self.send(counter) == self.target.send(counter) &&
                                                                     UserRateStatus.get(self.status) != UserRateStatus::Completed

      self.status = UserRateStatus.get(UserRateStatus::Watching) if prior_value == 0 &&
                                                                    self.send(counter) > 0 &&
                                                                    UserRateStatus.get(self.status) == UserRateStatus::Planned

      self.status = UserRateStatus.get(UserRateStatus::Planned) if prior_value > 0 &&
                                                                  self.send(counter) == 0# &&
                                                                  #UserRateStatus.get(self.status) == UserRateStatus::Watching

      UserHistory.add(self.user_id, self.target, UserHistoryAction.const_get(counter.capitalize), self.send(counter), prior_value) if self.save
    end
  end

  def update_score(value)
    value = value.to_i
    value = 10 if value > 10
    value = 0 if value < 0

    prior_score = self.score
    self.score = value

    UserHistory.add(self.user_id, self.target, UserHistoryAction::Rate, self.score, prior_score) if self.save
  end

  def check_data
    if target == nil
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
end
