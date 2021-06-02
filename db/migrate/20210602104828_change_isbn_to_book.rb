class ChangeIsbnToBook < ActiveRecord::Migration[6.0]
  def change
    change_column :books, :isbn, :string, null: false
  end
end
