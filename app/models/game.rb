class Game < ApplicationRecord
  belongs_to :player1, class_name: 'User'
  belongs_to :player2, class_name: 'User'
  validates :player1, presence: true
  validates :player2, presence: true
  validates :player1_score, presence: true
  validates :player2_score, presence: true
  validates :current_question_id, presence: true

  def next
    if player1_correct != 0 && player2_correct != 0
      self.player1_score += 1 if player1_correct == 1
      self.player2_score += 1 if player2_correct == 1
      self.current_question_id = Question.first.id # TODO: change this to a random question, given the topic, using GPT-3
      history << current_question_id
      self.player1_correct = 0
      self.player2_correct = 0

      save
    end
  end

  def answered(id, choice)
    correct = Question.find(current_question_id).options.find_index(&:correct)
    if choice == correct.to_s
      if player1_id == id
        self.player1_correct = 1
      else
        self.player2_correct = 1
      end
    elsif player1_id == id
      self.player1_correct = -1
    else
      self.player2_correct = -1
    end

    save
  end
end
