class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false, default: ''
      t.boolean :is_admin, default: false, null: false
      t.integer :balance, default: 0, null: false

      t.timestamps null: false
    end
  end
end
