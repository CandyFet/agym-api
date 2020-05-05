class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :login, null: false
      t.string :name
      t.string :email
      t.string :url
      t.string :avatar_url
      t.string :provider
      t.boolean :admin, default: false
      t.boolean :trainer, default: false
      t.boolean :ambassador, default: false

      t.timestamps
    end
  end
end
