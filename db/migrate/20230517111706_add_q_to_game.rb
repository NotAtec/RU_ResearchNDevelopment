class AddQToGame < ActiveRecord::Migration[7.0]
  def change
    add_reference :games, :current_question, foreign_key: { to_table: :questions }
    add_column :games, :history, :integer, array: true, default: []
  end
end
