class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users, id: :bigint do |t|
      t.string :email, limit: 255
      t.string :encrypted_password, limit: 255
      t.string :username, limit: 255
      t.string :display_name, limit: 255
      t.boolean :email_verified, default: false
      t.datetime :email_verified_at
      
      t.timestamps
    end
  end
end
