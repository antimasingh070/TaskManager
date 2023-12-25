class CreateOtps < ActiveRecord::Migration[6.1]
  def change
    create_table :otps do |t|
      t.string :code
      t.references :user, null: false, foreign_key: true
      t.datetime :expires_at

      t.timestamps
    end
  end
end
