class AddRecentChoiceToGame < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :player1_recent, :integer, default: -1
    add_column :games, :player2_recent, :integer, default: -1
  end
end
