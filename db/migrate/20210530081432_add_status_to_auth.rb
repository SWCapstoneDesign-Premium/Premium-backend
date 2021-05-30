class AddStatusToAuth < ActiveRecord::Migration[6.0]
  def change
    add_column :auths, :status, :integer, default: 0
  end
end
