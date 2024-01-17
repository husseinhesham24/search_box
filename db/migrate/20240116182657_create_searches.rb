class CreateSearches < ActiveRecord::Migration[7.1]
  def change
    create_table :searches do |t|
      t.string :query
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :searches, :query
  end
end
