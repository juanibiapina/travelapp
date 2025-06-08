class AddHasAccountToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :has_account, :boolean, default: true, null: false

    # Ensure existing users are marked as having accounts
    reversible do |dir|
      dir.up do
        User.update_all(has_account: true)
      end
    end
  end
end
