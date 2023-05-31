class MakeDefaultCorrectnessFalse < ActiveRecord::Migration[7.0]
  def change
    change_column_default :options, :correct, false
  end
end
