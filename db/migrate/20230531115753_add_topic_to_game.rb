class AddTopicToGame < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :topic, :string
  end
end