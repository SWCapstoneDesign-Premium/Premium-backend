class AddProjectIdToTutee < ActiveRecord::Migration[6.0]
  def change
    add_reference :users, :project, null: true, foreign_key: true
  end
end
