class CreateQuestions < ActiveRecord::Migration[7.0]
  def change
    create_table :questions do |t|
      t.string :text

      t.timestamps
    end

    add_reference :options, :question, foreign_key: true
  end
end
