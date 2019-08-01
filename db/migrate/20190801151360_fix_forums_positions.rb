class FixForumsPositions < ActiveRecord::Migration[5.2]
  def up
    Forum.find_by(id: 17)&.update position: 10
    Forum.find_by(id: 16)&.update position: 13
    Forum.find_by(id: 10)&.update position: 20
    Forum.find_by(id: 12)&.update position: 22
    Forum.find_by(id: 13)&.update position: 24
    Forum.find_by(id: 14)&.update position: 26
    Forum.find_by(id: 15)&.update position: 30
  end

  def down
    Forum.find_by(id: 17)&.update position: 5
    Forum.find_by(id: 16)&.update position: 6
    Forum.find_by(id: 10)&.update position: 9
    Forum.find_by(id: 12)&.update position: 10
    Forum.find_by(id: 13)&.update position: 11
    Forum.find_by(id: 14)&.update position: 14
    Forum.find_by(id: 15)&.update position: 15
  end
end
