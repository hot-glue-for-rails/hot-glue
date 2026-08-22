def login_as(user)
  visit '/users/sign_in'
  within("#new_user") do
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'password'
  end
  click_button 'Log in'

  # headless Chrome/Selenium occasionally drops this click without submitting
  # the form at all (confirmed via server log: no POST /users/sign_in received).
  # Retry once before failing for real.
  click_button 'Log in' unless page.has_content?('Signed in successfully', wait: 3)

  expect(page).to have_content("Signed in successfully")
end
