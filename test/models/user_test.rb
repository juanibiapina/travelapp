require "test_helper"

class UserTest < ActiveSupport::TestCase
  def google_auth_hash(email: "test@example.com", uid: "123456789")
    OmniAuth::AuthHash.new({
      provider: "google_oauth2",
      uid: uid,
      info: {
        email: email
      }
    })
  end

  test "should include omniauthable in devise modules" do
    assert User.devise_modules.include?(:omniauthable)
  end

  test "should have google_oauth2 as omniauth provider" do
    assert_includes User.omniauth_providers, :google_oauth2
  end

  test "should create user from omniauth" do
    auth = google_auth_hash

    assert_difference "User.count", 1 do
      user = User.from_omniauth(auth)
      assert user.persisted?
      assert_equal "test@example.com", user.email
      assert_equal "google_oauth2", user.provider
      assert_equal "123456789", user.uid
      assert user.valid_password?(user.password) # Should have a generated password
    end
  end

  test "should find existing user by email from omniauth" do
    existing_user = User.create!(
      email: "existing@example.com",
      password: "password123"
    )

    auth = google_auth_hash(email: "existing@example.com")

    assert_no_difference "User.count" do
      user = User.from_omniauth(auth)
      assert_equal existing_user.id, user.id
      assert_equal "existing@example.com", user.email
      # Should update provider and uid for existing user
      assert_equal "google_oauth2", user.provider
      assert_equal "123456789", user.uid
    end
  end

  test "should handle multiple oauth providers for same email" do
    # Create user with Google OAuth first
    auth1 = google_auth_hash(email: "multi@example.com", uid: "111")
    user1 = User.from_omniauth(auth1)

    # Try to create/find user with same email but different uid
    auth2 = google_auth_hash(email: "multi@example.com", uid: "222")

    assert_no_difference "User.count" do
      user2 = User.from_omniauth(auth2)
      assert_equal user1.id, user2.id
      assert_equal "multi@example.com", user2.email
    end
  end
end
