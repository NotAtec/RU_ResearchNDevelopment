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
      self.player1_backup = player1_recent
      self.player2_backup = player2_recent
      self.player1_recent = -1
      self.player2_recent = -1
      
      save
    end
  end

  def answered(id, choice)
    correct = Question.find(current_question_id).options.find_index(&:correct)
    if player1_id == id
      self.player1_recent = choice
    else
      self.player2_recent = choice
    end

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

  def answered_by(id)
    if player1_id == id
      player1_correct != 0
    else
      player2_correct != 0
    end
  end

  def chosen_by(id, q)
    if id == player1_id
      player1_recent == -1 && player2_recent == -1 ? q.options[player1_backup.to_i] : q.options[player1_recent.to_i]
    else
      player1_recent == -1 && player2_recent == -1 ? q.options[player2_backup.to_i] : q.options[player2_recent.to_i]
    end
  end

  def winner
    if player1_score > player2_score
      "The winner is #{player1.username}"
    elsif player1_score < player2_score
      "The winner is #{player2.username}"
    else
      'The game ended in a tie'
    end
  end
end
