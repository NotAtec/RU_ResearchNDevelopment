class AddStuffToGame < ActiveRecord::Migration[7.0]
  def change
    # Add reference to player 1 and player 2
    add_reference :games, :player1, foreign_key: { to_table: :users }
    add_reference :games, :player2, foreign_key: { to_table: :users }
    # Add 2 columns to store scores
    add_column :games, :player1_score, :integer
    add_column :games, :player2_score, :integer
    # Add boolean to see if player 2 has accepted the game
    add_column :games, :player2_accepted, :boolean, default: false
    # Add integer to store if player 1 and 2 have answered (0), or incorrect/correct (-1/1)
    add_column :games, :player1_correct, :integer, default: 0
    add_column :games, :player2_correct, :integer, default: 0
  end
end
