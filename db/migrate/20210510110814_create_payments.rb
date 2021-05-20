class CreatePayments < ActiveRecord::Migration[6.0]
  def change
    create_table :payments do |t|
      t.references :user, null: true, foreign_key: true
      t.timestamps
    end
  end
end
