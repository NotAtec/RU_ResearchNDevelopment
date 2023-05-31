class UpdateGameDefaults < ActiveRecord::Migration[7.0]
  def change
    # Make default scores 0
    change_column_default :games, :player1_score, 0
    change_column_default :games, :player2_score, 0

    # Make current question id nullable
    change_column_null :games, :current_question_id, true
    change_column_default :games, :current_question_id, nil
  end
end
