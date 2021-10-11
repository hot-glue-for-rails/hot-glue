def login_as(account)
  visit '/accounts/sign_in'
  within("#new_account") do
    fill_in 'Email', with: account.email
    fill_in 'Password', with: 'password'
  end
  click_button 'Log in'
end
