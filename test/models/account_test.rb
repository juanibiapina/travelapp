require "test_helper"

class AccountTest < ActiveSupport::TestCase
  def google_auth_hash(email: "test@example.com", uid: "123456789", name: "Test User", image: "https://example.com/picture.jpg")
    hash = OmniAuth::AuthHash.new({
      provider: "google",
      uid: uid,
      info: {
        email: email,
        name: name,
        image: image
      }
    })
    
    # Manually override the name if it should be nil
    if name.nil?
      hash.info.delete(:name)
    end
    
    hash
  end

  test "should include omniauthable in devise modules" do
    assert Account.devise_modules.include?(:omniauthable)
  end

  test "should have google as omniauth provider" do
    assert_includes Account.omniauth_providers, :google
  end

  test "should create account and user from omniauth" do
    auth = google_auth_hash

    assert_difference "Account.count", 1 do
      assert_difference "User.count", 1 do
        account = Account.from_omniauth(auth)
        assert account.persisted?
        assert_equal "test@example.com", account.email
        assert_equal "google", account.provider
        assert_equal "123456789", account.uid
        assert_equal "Test User", account.user.name
        assert_equal "https://example.com/picture.jpg", account.user.picture
        assert account.valid_password?(account.password) # Should have a generated password
      end
    end
  end

  test "should find existing account by email from omniauth" do
    user = User.create!(name: "Existing User")
    existing_account = Account.create!(
      user: user,
      email: "existing@example.com",
      password: "password123"
    )

    auth = google_auth_hash(email: "existing@example.com", name: "Updated User", image: "https://example.com/existing.jpg")

    assert_no_difference "Account.count" do
      assert_no_difference "User.count" do
        account = Account.from_omniauth(auth)
        assert_equal existing_account.id, account.id
        assert_equal "existing@example.com", account.email
        assert_equal "google", account.provider
        assert_equal "123456789", account.uid
        assert_equal "Updated User", account.user.name
        assert_equal "https://example.com/existing.jpg", account.user.picture
      end
    end
  end

  test "should handle multiple oauth providers for same email" do
    user = User.create!(name: "Multi Provider User")
    account = Account.create!(
      user: user,
      email: "multi@example.com", 
      password: "password123",
      provider: "github",
      uid: "github123"
    )

    auth = google_auth_hash(email: "multi@example.com", uid: "google456", name: "Updated Name")

    assert_no_difference "Account.count" do
      returned_account = Account.from_omniauth(auth)
      assert_equal account.id, returned_account.id
      assert_equal "google", returned_account.provider
      assert_equal "google456", returned_account.uid
    end
  end

  test "should handle oauth data with missing name or picture" do
    auth_without_name = google_auth_hash(email: "missing_name@example.com", uid: "missing_name_uid", name: nil, image: nil)

    assert_difference "Account.count", 1 do
      account = Account.from_omniauth(auth_without_name)
      assert account.persisted?
      # When name is nil, it should use email prefix as name
      assert_equal "missing_name", account.user.name
      assert_nil account.user.picture
    end

    # Test with empty string name/picture
    auth_with_empty_strings = google_auth_hash(email: "empty@example.com", uid: "empty_uid", name: "", image: "")

    assert_difference "Account.count", 1 do
      account = Account.from_omniauth(auth_with_empty_strings)
      assert account.persisted?
      # When name is empty string, it should use email prefix as name
      assert_equal "empty", account.user.name
      assert_equal "", account.user.picture
    end
  end

  test "should validate presence of email" do
    user = User.create!(name: "Test User")
    account = Account.new(user: user)
    assert_not account.valid?
    assert_includes account.errors[:email], "can't be blank"
  end

  test "should validate uniqueness of email" do
    user1 = User.create!(name: "User 1")
    user2 = User.create!(name: "User 2")
    
    Account.create!(user: user1, email: "unique@example.com", password: "password123")
    
    duplicate_account = Account.new(user: user2, email: "unique@example.com", password: "password123")
    assert_not duplicate_account.valid?
    assert_includes duplicate_account.errors[:email], "has already been taken"
  end

  test "should validate presence of password for new accounts" do
    user = User.create!(name: "Test User")
    account = Account.new(user: user, email: "test@example.com")
    assert_not account.valid?
    assert_includes account.errors[:password], "can't be blank"
  end
end
