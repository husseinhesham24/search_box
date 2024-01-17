class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :ip

      t.timestamps
    end
    add_index :users, :ip
  end
end
