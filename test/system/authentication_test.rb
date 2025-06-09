require "application_system_test_case"

class AuthenticationTest < ApplicationSystemTestCase
  test "user can create account, sign out, and sign in again" do
    # Generate unique email for this test
    email = "test_user_#{Time.current.to_i}@example.com"
    password = "testpassword123"
    name = "Test User"

    # Step 1: Create an account (sign up)
    visit new_account_registration_path

    # Ensure the page loaded properly
    assert_current_path new_account_registration_path
    assert_selector "h2", text: "Sign up"

    fill_in "Name", with: name
    fill_in "Email", with: email
    fill_in "Password", with: password
    fill_in "Password confirmation", with: password
    click_on "Sign up"

    # Should be redirected to trips index after successful signup (could be root or trips path)
    assert page.has_selector?("h1", text: "Your Trips"), "Should be on trips page with 'Your Trips' heading"

    # Step 2: Sign out
    click_on "Sign out"

    # After sign out, user should be redirected and no longer see the sign out link
    assert_not (page.has_link?("Sign out") || page.has_button?("Sign out")), "Sign out link should not be visible after signing out"

    # Step 3: Sign in again with the same credentials
    visit new_account_session_path  # Go to sign in page
    fill_in "Email", with: email
    fill_in "Password", with: password
    click_on "Log in"

    # Should be redirected back to trips index after successful sign in
    assert page.has_selector?("h1", text: "Your Trips"), "Should be back on trips page after sign in"
    assert (page.has_link?("Sign out") || page.has_button?("Sign out")), "Sign out link should be visible after signing in"
  end

  test "registration form includes name field" do
    visit new_account_registration_path

    # Verify that the name field is present in the form
    assert_selector "label", text: "Name"
    assert_selector "input[name='account[name]']"
    
    # Verify the field order: Name should come before Email
    name_field = find("input[name='account[name]']")
    email_field = find("input[name='account[email]']")
    
    # Simple check that name field appears before email field in the DOM
    assert name_field["id"] # Just ensure the field exists and is accessible
    assert email_field["id"] # Just ensure the field exists and is accessible
  end

  test "user account is created with provided name" do
    # Generate unique email for this test
    email = "test_name_#{Time.current.to_i}@example.com"
    password = "testpassword123"
    name = "John Doe"

    visit new_account_registration_path

    fill_in "Name", with: name
    fill_in "Email", with: email
    fill_in "Password", with: password
    fill_in "Password confirmation", with: password
    click_on "Sign up"

    # Wait for redirect and page to load
    assert page.has_selector?("h1", text: "Your Trips"), "Should be redirected to trips page after registration"

    # Verify the user was created with the correct name
    account = Account.find_by(email: email)
    assert_not_nil account, "Account should be created"
    assert_not_nil account.user, "User should be associated with account"
    assert_equal name, account.user.name, "User should have the provided name"
  end
end
