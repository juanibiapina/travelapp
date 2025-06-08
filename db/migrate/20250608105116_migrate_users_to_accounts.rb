class MigrateUsersToAccounts < ActiveRecord::Migration[8.0]
  def up
    # For each user with an account, create a corresponding Account record
    User.where(has_account: true).find_each do |user|
      Account.create!(
        user_id: user.id,
        email: user.email || '',
        encrypted_password: user.encrypted_password || '',
        reset_password_token: user.reset_password_token,
        reset_password_sent_at: user.reset_password_sent_at,
        remember_created_at: user.remember_created_at,
        provider: user.provider,
        uid: user.uid
      )
    end
  end
  
  def down
    # Remove all accounts
    Account.delete_all
  end
end
