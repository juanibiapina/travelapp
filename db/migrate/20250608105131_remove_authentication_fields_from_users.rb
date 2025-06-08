class RemoveAuthenticationFieldsFromUsers < ActiveRecord::Migration[8.0]
  def change
    # Remove authentication-related fields from users
    remove_column :users, :email, :string
    remove_column :users, :encrypted_password, :string
    remove_column :users, :reset_password_token, :string
    remove_column :users, :reset_password_sent_at, :datetime
    remove_column :users, :remember_created_at, :datetime
    remove_column :users, :provider, :string
    remove_column :users, :uid, :string
    remove_column :users, :has_account, :boolean

    # Remove email and provider/uid indexes
    remove_index :users, :email if index_exists?(:users, :email)
    remove_index :users, [ :provider, :uid ] if index_exists?(:users, [ :provider, :uid ])
    remove_index :users, :reset_password_token if index_exists?(:users, :reset_password_token)
  end
end
