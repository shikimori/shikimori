class People::JobsWorker
  include Sidekiq::Worker

  PEOPLE_WITH_CUSTOMIZED_ROLES_IDS = [6024]

  def perform
    Person.transaction do
      scope.update_all is_producer: false, is_mangaka: false, is_seyu: false

      scope.where(id: producer_ids).update_all is_producer: true
      scope.where(id: mangaka_ids).update_all is_mangaka: true
      scope.where(id: seyu_ids).update_all is_seyu: true
    end
  end

private

  def scope
    Person.where.not(id: PEOPLE_WITH_CUSTOMIZED_ROLES_IDS)
  end

  def producer_ids
    PersonRole
      .where.not(person_id: nil)
      .where("roles && '{Chief Producer,Director}'")
      .pluck(:person_id)
      .uniq
  end

  def mangaka_ids
    PersonRole
      .where.not(person_id: nil)
      .where("roles && '{#{Person::MANGAKA_ROLES.join(',')}}'")
      .pluck(:person_id)
      .uniq
  end

  def seyu_ids
    PersonRole
      .where.not(person_id: nil)
      .where("roles && '{#{Person::SEYU_ROLES.join(',')}}'")
      .pluck(:person_id)
      .uniq
  end
end
