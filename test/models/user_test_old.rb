require "test_helper"

class UserTest < ActiveSupport::TestCase
  def google_auth_hash(email: "test@example.com", uid: "123456789", name: "Test User", image: "https://example.com/picture.jpg")
    OmniAuth::AuthHash.new({
      provider: "google",
      uid: uid,
      info: {
        email: email,
        name: name,
        image: image
      }
    })
  end

  test "should include omniauthable in devise modules" do
    assert User.devise_modules.include?(:omniauthable)
  end

  test "should have google as omniauth provider" do
    assert_includes User.omniauth_providers, :google
  end

  test "should create user from omniauth" do
    auth = google_auth_hash

    assert_difference "User.count", 1 do
      user = User.from_omniauth(auth)
      assert user.persisted?
      assert_equal "test@example.com", user.email
      assert_equal "google", user.provider
      assert_equal "123456789", user.uid
      assert_equal "Test User", user.name
      assert_equal "https://example.com/picture.jpg", user.picture
      assert user.valid_password?(user.password) # Should have a generated password
    end
  end

  test "should find existing user by email from omniauth" do
    existing_user = User.create!(
      email: "existing@example.com",
      password: "password123"
    )

    auth = google_auth_hash(email: "existing@example.com", name: "Existing User", image: "https://example.com/existing.jpg")

    assert_no_difference "User.count" do
      user = User.from_omniauth(auth)
      assert_equal existing_user.id, user.id
      assert_equal "existing@example.com", user.email
      # Should update provider, uid, name, and picture for existing user
      assert_equal "google", user.provider
      assert_equal "123456789", user.uid
      assert_equal "Existing User", user.name
      assert_equal "https://example.com/existing.jpg", user.picture
    end
  end

  test "should handle multiple oauth providers for same email" do
    # Create user with Google OAuth first
    auth1 = google_auth_hash(email: "multi@example.com", uid: "111", name: "Multi User", image: "https://example.com/multi1.jpg")
    user1 = User.from_omniauth(auth1)

    # Try to create/find user with same email but different uid
    auth2 = google_auth_hash(email: "multi@example.com", uid: "222", name: "Multi User Updated", image: "https://example.com/multi2.jpg")

    assert_no_difference "User.count" do
      user2 = User.from_omniauth(auth2)
      assert_equal user1.id, user2.id
      assert_equal "multi@example.com", user2.email
      # Should update to the latest OAuth data
      assert_equal "Multi User Updated", user2.name
      assert_equal "https://example.com/multi2.jpg", user2.picture
    end
  end

  test "should handle oauth data with missing name or picture" do
    # Test with missing name - OmniAuth falls back to email for name
    auth_no_name = OmniAuth::AuthHash.new({
      provider: "google",
      uid: "no_name",
      info: {
        email: "no_name@example.com",
        image: "https://example.com/picture.jpg"
      }
    })

    user = User.from_omniauth(auth_no_name)
    assert user.persisted?
    assert_equal "no_name@example.com", user.name  # OmniAuth falls back to email
    assert_equal "https://example.com/picture.jpg", user.picture

    # Test with missing picture
    auth_no_picture = OmniAuth::AuthHash.new({
      provider: "google",
      uid: "no_picture",
      info: {
        email: "no_picture@example.com",
        name: "User With No Picture"
      }
    })

    user2 = User.from_omniauth(auth_no_picture)
    assert user2.persisted?
    assert_equal "User With No Picture", user2.name
    assert_nil user2.picture
  end

  test "should create user without account" do
    user = User.new(name: "John Doe", has_account: false)
    assert user.valid?
    assert user.save
    assert_equal "John Doe", user.name
    assert_equal false, user.has_account?
    assert_nil user.email
    assert_nil user.encrypted_password
  end

  test "should require name for users without account" do
    user = User.new(has_account: false)
    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
  end

  test "should not require email or password for users without account" do
    user = User.new(name: "Jane Doe", has_account: false)
    assert user.valid?
    assert_nil user.email
    assert_nil user.encrypted_password
  end

  test "should require email and password for users with account" do
    user = User.new(has_account: true)
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
    assert_includes user.errors[:encrypted_password], "can't be blank"
  end

  test "should default has_account to true" do
    user = User.new(email: "test@example.com", password: "password123")
    assert user.has_account?
  end

  test "scope with_account should return only users with accounts" do
    with_account = User.create!(email: "with@example.com", password: "password123")
    without_account = User.create!(name: "No Account User", has_account: false)

    users_with_account = User.with_account
    assert_includes users_with_account, with_account
    assert_not_includes users_with_account, without_account
  end

  test "scope without_account should return only users without accounts" do
    with_account = User.create!(email: "with@example.com", password: "password123")
    without_account = User.create!(name: "No Account User", has_account: false)

    users_without_account = User.without_account
    assert_includes users_without_account, without_account
    assert_not_includes users_without_account, with_account
  end
end
