class Game < ApplicationRecord
  belongs_to :player1, class_name: 'User'
  belongs_to :player2, class_name: 'User'
  validates :player1, presence: true
  validates :player2, presence: true
  validates :player1_score, presence: true
  validates :player2_score, presence: true
end
