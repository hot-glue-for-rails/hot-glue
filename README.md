
![Integrated Logo design-639x264](https://user-images.githubusercontent.com/59002/189544688-c1a8226f-9dbd-4758-bc0c-712fc2754cbd.png)

Hot Glue is a Rails scaffold builder for the Turbo era. It is an evolution of the admin-interface style scaffolding systems of the 2010s ([activeadmin](https://github.com/activeadmin/activeadmin), [rails_admin](https://github.com/sferik/rails_admin), and [active_scaffold](https://github.com/activescaffold/active_scaffold)).

Using Turbo-Rails and Hotwire (default in Rails 7) you get a lightning-fast out-of-the-box CRUD-building experience.

Every page displays only a list view: new and edit operations happen as 'edit-in-place,' so the user never leaves the page.

Because all page navigation is Turbo's responsibility, everything plugs & plays nicely into a Turbo-backed Rails app.

Alternatively, you can use this tool to create a Turbo-backed *section* of your Rails app -- such as an admin interface -- while still treating the rest of the Rails app as an API or building out other features by hand.

It will read your relationships and field types to generate your code for you, leaving you with a 'sourdough starter' to work from. If you modify the generated code, you're on your own if you want to preserve your changes and also re-generate scaffolding after adding fields.

By default, it generates code that gives users full control over objects they 'own' and by default it spits out functionality giving access to all fields.

Hot Glue generates functionality that is quick and dirty. It lets you be crafty. As with a real glue gun, use it with caution.

* Build plug-and-play scaffolding mixing generated ERB with the power of Hotwire and Turbo-Rails
* Everything edits-in-place (unless you use `--big-edit`)
* Automatically reads your models (make them AND migrate your database before building your scaffolding!)
* Excellent for CREATE-READ-UPDATE-DELETE (CRUD), lists with pagination
* Great for prototyping, but you should learn Rails fundamentals first.
* 'Packaged' with Devise, Kaminari, Rspec, FontAwesome
* Create system specs automatically along with the generated code.
* Nest your routes model-by-model for built-in poor man's authentication.
* Throw the scaffolding away when your app is ready to graduate to its next phase.


# Get Hot Glue

## [GET THE COURSE TODAY](https://jfbcodes.com/courses/hot-glue-in-depth-tutorial/?utm_source=github.com&utm_campaign=github_hot_glue_readme_page) **only $60 USD!**


[![Hot Glue Course](https://user-images.githubusercontent.com/59002/189544503-6edbcd40-1728-4b13-ac9a-c7772ccb8284.jpg)](https://jfbcodes.com/courses/hot-glue-in-depth-tutorial/?utm_source=github.com&utm_campaign=github_hot_glue_readme_page)

---


## GETTING STARTED VIDEO


~~Check it out on Youtube at https://www.youtube.com/watch?v=bKjKHMTvzZc~~

While you're over there could you give my Youtube channel a 'Subscribe'? (look for the RED SUBSCRIBE BUTTON)


---
## HOW EASY?

```
rails generate hot_glue:scaffold Thing 
```

Generate a quick scaffold to manage a table called `pronouns`
![hot-glue-3](https://user-images.githubusercontent.com/59002/116405509-bdee2f00-a7fd-11eb-9723-4c6e22f81bd3.gif)

Instantly get a simple CRUD interface

![hot-glue-4](https://user-images.githubusercontent.com/59002/116405517-c2b2e300-a7fd-11eb-8423-d43e3afc9fa6.gif)

# Getting Started

_If you are on Rails 6, see [LEGACY SETUP FOR RAILS 6](https://github.com/jasonfb/hot-glue/README2.md) and complete those steps FIRST._


## 1. Rails 7 New App

To run Turbo (which Hot Glue requires), you must either (1) be running an ImportMap-Rails app, or (2) be running a Node-compiled app using any of JSBundling, Shakapacker, or its alternatives. 

For reference, see https://jasonfleetwoodboldt.com/courses/stepping-up-rails/rails-7-do-i-need-importmap-rails/

(1) To use ImportMap Rails, start with
`rails new`

If you want Bootstrap, install it following [these instructions](https://jasonfleetwoodboldt.com/courses/stepping-up-rails/importmap-rails-with-bootstrap-sprockets-stimulus-and-turbo-long-tutorial/)

(2) To use JSBundling, start with
`rails new --javascript=jsbundling`


**If using JSBundling, make sure to use the new `./bin/dev` to start your server instead of the old `rails server` or else your Turbo interactions will not work correctly.**
If you want Bootstrap, install it following these instructions

(3) To use Shakapacker, start with `rails new --skip-javascript` and [see this post](https://jasonfleetwoodboldt.com/courses/react-heart-rails/rails-7-shakapacker-and-reactonrails-quick-setup-part-1/)

For the old method of installing Bootstrap [see this post](https://jasonfleetwoodboldt.com/courses/stepping-up-rails/rails-7-bootstrap/)

Remember, for Rails 6 you must go through the [LEGACY SETUP FOR RAILS 6](https://github.com/jasonfb/hot-glue/blob/main/README2.md) before continuing. 


## The Super-Quick Setup

Be sure to do `git add .` and `git commit -m "initial commit"` after creating your new Rails 7 app.

```
bundle add rspec-rails factory_bot_rails ffaker --group "development, test" && 
git add . && git commit -m "adds gems" && 
rails generate rspec:install && 
git add . && git commit -m "adds rspec" && 
rm app/assets/stylesheets/application.css &&
echo "" > app/assets/stylesheets/application.scss && 
sed -i '' -e  's/# gem "sassc-rails"//g' Gemfile && sed -i '' -e 's/# Use Sass to process CSS//g' Gemfile && 
bundle install && bundle add sassc-rails && git add . && git commit -m "adds sassc-rails" && 
rm -rf test/ && git add . && git commit -m "removes minitest" && 
bundle add hot-glue && git add . && git commit -m "adds hot-glue" && 
rails generate hot_glue:install --layout=bootstrap && 
git add . && git commit -m "hot glue setup" &&
bundle add font_awesome5_rails && 
echo "*= require font_awesome5_webfont" > app/assets/stylesheets/application.scss && 
git add . && git commit -m "adds fontawesome" &&  
bundle add devise && bundle install && 
git add . && git commit -m "adding devise gem" && 
rails generate devise:install && 
rails g devise:views && 
sed -i '' -e  's/Rails.application.configure do/Rails.application.configure do\n  config.action_mailer.default_url_options = { host: "localhost", port: 3000 }/g' config/environments/development.rb && 
sed -i '' -e  's/# root "articles#index"//g' config/routes.rb && 
sed -i '' -e  's/Rails.application.routes.draw do/Rails.application.routes.draw do\n  root to: "welcome#index"/g' config/routes.rb && 
git add . && git commit -m 'devise view fixes' &&
rails generate controller Welcome &&
git add . && git commit -m "generates Welcome controller" &&
sed -i '' -e 's/html: { method: :post }/html: { method: :post, 'data-turbo': false}/g' app/views/devise/confirmations/new.html.erb &&
sed -i '' -e 's/ url: session_path(resource_name))/ url: session_path(resource_name), html: {"data-turbo": false})/g' app/views/devise/sessions/new.html.erb && 
sed -i '' -e 's/ url: registration_path(resource_name))/ url: registration_path(resource_name), html: {"data-turbo": false})/g' app/views/devise/registrations/new.html.erb && 
sed -i '' -e 's/, html: { method: :post })/, html: { method: :post, "data-turbo": false })/g' app/views/devise/passwords/new.html.erb && 
git add . && git commit -m 'devise view fixes' &&
rails generate model User name:string &&
rails generate devise User && git add . && git commit -m "adds Users model with devise" && 
rails db:migrate &&
git add . && git commit -m "schema file"
```

## Step-By-Step Setup

### 2. ADD RSPEC, FACTORY-BOT, AND FFAKER

add these 3 gems to your gemfile **inside a group for both :development and :test*. 
Do not add these gems to *only* the :test group or else your Rspec installer and generators will not work correctly.
```
group :development, :test do 
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'ffaker'
end 
```

#### Rspec Installer
- run `rails generate rspec:install`

- Because you are not using Minitest, you can delete the `test/` folder at the root of your repository.



### 3. HOTGLUE INSTALLER
Add `gem 'hot-glue'` to your Gemfile & `bundle install`

During in installation, you MUST supply a `--layout` flag.

#### `--layout` flag (only two options: `hotglue` or `bootstrap`; default is `bootstrap`) 
Here you will set up and install Hot Glue for the first time. 

It will install a config file that will save two preferences: layout (`hotglue` or `bootstrap`)

The installer will create `config/hot_glue.yml`. 


#### `--theme` flag 
During the installation, **if** your `--layout` flag is set to `hotglue` you must also pass `--theme` flag.

the themes are:
• like_mountain_view (Google)
• like_los_gatos (Netflix)
• like_bootstrap (bootstrap 4 copy)
• dark_knight (_The Dark Night_ (2008) inspired)
• like_cupertino (modern Apple-UX inspired)


#### `--markup` flag (NOTE: haml and slim are no longer supported at this time)

default is `erb`. IMPORTANT: As of right now, HAML and SLIM are not currently supported so the only option is also the default `erb`.


#### example installing ERB using Bootstrap layout:
`rails generate hot_glue:install --markup=erb --layout=bootstrap`

#### Example installing using Hot Glue layout and the 'like_mountain_view' (Gmail-inspired) theme:
`rails generate hot_glue:install --markup=erb --layout=hotglue --theme=like_mountain_view`

The Hot Glue installer did several things for you in this step. Examine the git diffs or see 'Hot Glue Installer Notes' below.


### 4. Font-awesome (optional)

I recommend
https://github.com/tomkra/font_awesome5_rails
or
https://github.com/FortAwesome/font-awesome-sass


### 5. Devise
(If you are on Rails 6, you must do ALL of the steps in the Legacy Setup steps. Be sure not to skip **Legacy Step #5** below)
https://github.com/jasonfb/hot-glue/blob/main/README2.md

You MUST run the installer FIRST or else you will put your app into a non-workable state:
```
rails generate devise:install
```

IMPORTANT: Follow the instructions the Devise installer gives you, *Except Step 3*, you can skip this step:
```
 3. Ensure you have flash messages in app/views/layouts/application.html.erb.
     For example:

       <p class="notice"><%= notice %></p>
       <p class="alert"><%= alert %></p>

```

Be sure to create primary auth model with:

`rails generate devise User name:string`

Remember, you don't need to tell Devise that your User has an email, an encrypted password, a reset token, and a 'remember me' flag to let the user stay logged in.

Those features come by default with Devise, and you'll find the fields for them in the newly generated migration file. 

In this example above, you are creating all of those fields along with a simple 'name' (string) field for your User table.


!!! Warning: as of 2022-09-19, Devise is still not compatible out-of-the-box with Rails Turbo.

To fix this, run
`rails generate devise:views`


Then manually add `html: {'data-turbo' => "false"}` to all of the Devise forms. You will need to edit the following forms:
`views/devise/sessions/new.html.erb`, `views/devise/registrations/edit.html.erb`, 
`views/devise/registrations/new.html.erb`, and  

Add the data-turbo false option in the html key of the form, shown in bold here: 

form_for(resource, as: resource_name, **html: {'data-turbo' => "false"},** url: session_path(resource_name) ) do |f|


#### Hot Glue Installer Notes 

These things were **done for you** in Step #3 (above). You don't need to think about them but if you are familiar with Capybara and/or adding Hot Glue to an existing app, you may want to:

#####  Hot Glue modified `application.html.erb`
Note: if you have some kind of non-standard application layout, like one at a different file
or if you have modified your opening <body> tag, this may not have been automatically applied by the installer.

- This was added to your `application.html.erb`
```
  <%= render partial: 'layouts/flash_notices' %>
```

##### Hot Glue modified `rails_helper.rb`
Note: if you have some kind of non-standard rails_helper.rb, like one that does not use the standard ` do |config|` syntax after your `RSpec.configure`
this may not have been automatically applied by the installer.

- configure Rspec to work with Factory Bot inside of `rails_helper.rb`
  ```
  RSpec.configure do |config|
      // ... more rspec configuration (not shown)
      config.include FactoryBot::Syntax::Methods
  end
  ```  


##### Hot Glue switched Capybara from RACK-TEST to HEADLESS CHROME

- By default Capybara is installed with :rack_test as its driver.
- This does not support Javascript. Hot Glue is not targeted for fallback browsers.
- From the [Capybara docs](https://github.com/teamcapybara/capybara#drivers):
```
By default, Capybara uses the :rack_test driver, which is fast but limited: it does not support JavaScript
```

- To fix this, you must switch to a Javascript-supporting Capybara driver. You can choose one of:

`Capybara.default_driver = :selenium`
`Capybara.default_driver = :selenium_chrome`
`Capybara.default_driver = :selenium_chrome_headless`

By default, the installer should have added this option to your `rails_helper.rb` file:

```
Capybara.default_driver = :selenium_chrome_headless 
```

Alternatively, you can define your own driver like so:

  ```
  Capybara.register_driver :my_headless_chrome_desktop do |app|
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    options.add_argument('--disable-gpu')
    options.add_argument('--window-size=1280,1200')
    
    driver = Capybara::Selenium::Driver.new(app,
                                            browser: :chrome,
                                            options: options)
    
    driver
  end
  Capybara.default_driver = :my_headless_chrome_desktop
    
  ```

##### Hot Glue Added a Quick (Old-School) Capybara Login For Devise

- for a quick Capybara login, create a support helper in `spec/support/` and log-in as your user
- in the default code, the devise login would be for an object called account and lives at the route `/accounts/sign_in`
- modify the generated code (it was installed by the installed) for your devise login
   ```
   def login_as(account)
     visit '/accounts/sign_in'
     within("#new_account") do
     fill_in 'Email', with: account.email
     fill_in 'Password', with: 'password'
     end
     click_button 'Log in'
   end
   ```

---
---
---

# HOT GLUE DOCS

## First Argument
(no double slash)

TitleCase class name of the thing you want to build a scaffoling for.

rails generate hot_glue:scaffold Thing

(note: Your Thing object must belong_to an authenticated User or alternatively you must create a Gd controller, see below.)

## Options With Arguments

All options two dashes (--) and these take an `=` and a value

### `--namespace=`

pass `--namespace=` as an option to denote a namespace to apply to the Rails path helpers


`rails generate hot_glue:scaffold Thing --namespace=dashboard`

This produces several views at `app/views/dashboard/things/` and a controller at`app/controllers/dashboard/things_controller.rb`

The controller looks like so:

```
class Dashboard::ThingsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_thing, only: [:show, :edit, :update, :destroy]
  def load_thing
    @thing = current_user.things.find(params[:id])
  end
  ...
end

```


### `--nested=`

This object is nested within another tree of objects, and there is a nested route in your `routes.rb` file with the specified parent controllers above this controller. When specifying the parent(s), be sure to use **singular case**.

#### Example #1: One-level Nesting
Invoice `has_many :lines` and a Line `belongs_to :invoice`

```
resources :invoices do
  resource :lines do
end
```

`rails generate hot_glue:scaffold Invoice`

`rails generate hot_glue:scaffold Line --nested=invoice`


Remember, nested should match how the hierarchy of nesting is in your `routes.rb` file. (Which Hot Glue does not create or edit for you.)

#### Example #2: Two-level Nesting

Invoice `has_many :lines` and a Line `belongs_to :invoice`
Line `has_many :charges` and Charge `belongs_to :line`

**config/routes.rb**
```
resources :invoices do
    resources :lines do
        resources :charge
    end    
end
```


_For multi-level nesting use slashes to separate your levels of nesting._

`rails generate hot_glue:scaffold Invoice`

`rails generate hot_glue:scaffold Line --nested=invoice`

`rails generate hot_glue:scaffold Charge --nested=invoice/line`



For non-Gd controllers, your auth root will be used as the starting point when loading the objects from the URL if this object is nested.

(For Gd controllers the root object will be loaded directly from the ActiveRecord object.)

In the example above, @invoice will be loaded from

`@invoice = current_user.invoices.find(params[:invoice_id])`

Then, @line will be loaded

`@line = @invoice.lines.find(params[:line_id])`

Then, finally the @charge will be loaded

`@charge = @line.charges.find(params[:id])`

This is "starfish access control" or "poor man's access control."  It works when the current user has several things they can manage, and by extension can manage children of those things.  


#### Optionalized Nested Parents

Add `~` in front of any nested parameter (any parent in the `--nested` list) you want to make optional. This creates a two-headed controller: It can operate with or without that optionalized parameter.

This is an advanced feature. To use, **make duplicative routes to the same controller**. You can only use this feature with Gd controller.  

Specify your controller *twice* in your routes.rb. Then, in your `--nested` setting, add `~` to any nested parent you want to **make optional**. "Make optional" means the controller will behave as-if it exists in two places: once, at the normal nest level.  Then the same controller will 'exist' again one-level up in your routes. **If the route has sub-routes, you'll need to re-specify the entire subtree also**.
```
namespace :admin
  resources :users do
    resources :invoices
  end
  resources :invoices
end
```

Even though we have two routes pointed to **invoices**, both will go to the same controller (`app/controllers/admin/invoices_controller.rb`)

```
rails generate hot_glue:scaffold User --namespace=admin --gd
rails generate hot_glue:scaffold Invoice --namespace=admin --gd --nested=~users
```
Notice for the Invoice build, the parent user is *optionalized* (not 'optional'-- optionalized: to be made so it can be made optional).  

The Invoices controller, which is a Gd controller, will load the User if a user is specified in the route (`/admin/users/:user_id/invoices/`). It will ALSO work at `/admin/invoices` and will switch back into loading directly from the base class when routed without the parent user.


                                                         
### `--auth=`

By default, it will be assumed you have a `current_user` for your user authentication. This will be treated as the "authentication root" for the "poor man's auth" explained above.

The poor man's auth presumes that object graphs have only one natural way to traverse them (that is, one primary way to traverse them), and that all relationships infer that a set of things or their descendants are granted access to "me" for reading, writing, updating, and deleting.

Of course this is a sloppy way to do access control, and can easily leave open endpoints your real users shouldn't have access to.

When you display anything built with the scaffolding, Hot Glue assumes the `current_user` will have `has_many` association that matches the pluralized name of the scaffold. In the case of nesting, we will automatically find the nested objects first, then continue down the nest chain to find the target object. This is how Hot Glue assumes all object are 'anchored' to the logged-in user. (As explained in the `--nested` section.)

If you use Devise, you probably already have a `current_user` method available in your controllers. If you don't use Devise, you can implement it in your ApplicationController.

If you use a different object other than "User" for authentication, override using the `auth` option.

`rails generate hot_glue:scaffold Thing --auth=current_account`

You will note that in this example it is presumed that the Account object will have an association for `things`

It is also presumed that when viewing their own dashboard of things, the user will want to see ALL of their associated things.

If you supply nesting (see below), your nest chain will automatically begin with your auth root object (see nesting)


### `--auth_identifier=`

Your controller will call a method authenticate_ (AUTH IDENTIFIER) bang, like:

`authenticate_user!`

Before all of the controller actions. If you leave this blank, it will default to using the variable name supplied by auth with "current_" stripped away.
(This is setup for devise.)

Be sure to implement the following method in your ApplicationController or some other method. Here's a quick example using Devise. You will note in the code below, user_signed_in? is implemented when you add Devise methods to your User table.

As well, the `after_sign_in_path_for(user)` here is a hook for Devise also that provides you with after login redirect to the page where the user first intended to go.

```
  def authenticate_user!
    if ! user_signed_in?
      session['user_return_to'] = request.path
      redirect_to new_user_registration_path
    end
  end

  def after_sign_in_path_for(user)
    session['user_return_to'] || account_url(user)
  end
```


The default (do not pass `auth_identifier=`) will match the `auth` (So if you use 'account' as the auth, `authenticate_account!` will get invoked from your generated controller; the default is always 'user', so you can leave both auth and auth_identifier off if you want 'user')


`rails generate hot_glue:scaffold Thing --auth=current_account --auth_identifier=login`

 
In this example, the controller produced with:
```
   before_action :authenticate_login!
```
However, the object graph anchors would continue to start from current_account. That is,
```
@thing = current_account.things.find(params[:id])
```

Use empty string to **turn this method off**:
 
`rails generate hot_glue:scaffold Thing --auth=current_account --auth_identifier=''`

In this case a controller would be generated that would have NO before_action to authenticate the account, but it would still treat the current_account as the auth root for the purpose of loading the objects.

Please note that this example would produce non-functional code, so you would need to manually fix your controllers to make sure `current_account` is available to the controller.


### `--hawk=`

Hawk a foreign key that is not the object's owner to within a specified scope. 

Assuming a Pet belong_to a :human, when building an Appointments scaffold, you can hawk the `pet_id` to the current human's pets. (Whoever is the authentication object.)

`--hawk=pet_id`

This is covered in [Example #3 in the Hot Glue Tutorial](https://jfb.teachable.com/courses/hot-glue-in-depth-tutorial/lectures/38584014)

To hawk to a scope that is not the currently authenticated user, use curly braces `{...}` to specify the scope.

`--hawk=user_id{current_user.family}`

This would hawk the Appointment's `user_id` key to any users who are within the scope of the current_user's family. 

This is covered in [Example #4 in the Hot Glue Tutorial](https://jfb.teachable.com/courses/hot-glue-in-depth-tutorial/lectures/38787505)


### `--plural=`

You don't need this if the pluralized version is just + "s" of the singular version.
Only use for non-standard plurlizations, and be sure to pass it as TitleCase (as if you pluralized the model name which is non-standard for Rails)

An better alternative is to define the non-standard plurlizations globally in your app.

Make a file at `config/initializers/inflections.rb`

# Add new inflection rules using the following format
```
ActiveSupport::Inflector.inflections do |inflect|
    inflect.irregular 'clothing', 'clothes'
    inflect.irregular 'human', 'humans'  
end
```

### `--form-labels-position` (default: `after`; options are **before**, **after**, and **omit**)
By default form labels appear after the form inputs. To make them appear before or omit them, use this flag.

See also `--form-placeholder-labels` to use placeolder labels. 



### `--exclude=`
(separate field names by COMMA)

By default, all fields are included unless they are on the default exclude list. (The default exclude list is `id`, `created_at`, `updated_at`, `encrypted_password`, `reset_password_token`, `reset_password_sent_at`, `remember_created_at`, `confirmation_token`, `confirmed_at`, `confirmation_sent_at`, `unconfirmed_email`.)

If you specify any exclude list, those excluded **and** the default exclude list will be excluded. (If you need any of the fields on the default exclude list, you must use `--include` instead.)


`rails generate hot_glue:scaffold Account --exclude=password`


### `--include=`
Separate field names by COMMA

If you specify an include list, it will be treated as a whitelist: no fields will be included unless specified on the include list.

`rails generate hot_glue:scaffold Account --include=first_name,last_name,company_name,created_at,kyc_verified_at`

You may not specify both include and exclude.

Include setting is affected by both specified grouping mode and smart layouts, explained below.


#### Specified Grouping Mode

To specify grouped columns, separate COLUMNS by a COLON, then separate fields with commas. Specified groupings work like smart layouts (see below), except you drive which groupings make up the columns. 

(Smart layouts, below, achieves the same effect but automatically group your fields into a smart number of columns.) 

If you want to group up fields together into columns, use a COLON (`:`) character to specify columns.

Your input **may** have a COLON at the end of it, but otherwise your columns will made **flush left**.

Without specified grouping (and not using smart layout), no grouping will happen. So these two fields would display in two (small, 1-column Bootstrap) columns:
 
`--include=first,last`

With a **trailing colon** you switch Hot Glue into specified grouping mode. You're telling Hot Glue to make the two fields into column #1. (There is no other column.)
`--include=first,last:`

Hot Glue also happens to know that, for example, when you say "one column" you really want _one visual_ column made up of the available Bootstrap columns. For example, with 1 child portal (4) + the default edit/create buttons (2), you would have 6 remaining bootstrap columns (2+4+6=12). With 6 remaining Bootstrap columns Hot Glue will make 1 _visual colum_ into a 6-column Bootstrap column.

If, for example, you wanted to put the `email` field into column #1 and then the `first` and `last` into column #2, you would use:
`--include=email:first,last`

Assuming we have the same number of columns as the above example (6), Hot Glue knows that you now have 2 _visual columns_. It then gives each visual column 3-colum bootstrap columns, which makes your layout into a 3+3+4+2=12 Bootstrap layout. 

**Specifying any colon in your include syntax switches the builder into specified grouping mode.** 
 
The effect will be that the fields will be stacked together into nicely fit columns. (This will look confusing if your end-user is expecting an Excel-like interface.)

With Hot Glue in specified grouping or smart layout mode, it automatically attempts to fit everything into Bootstrap 12-columns. 

Using Bootstrap with neither specified grouping nor smart layouts may make more than 12 columns, which will produce strange results. (Bootstrap is not designed to work with, for example, a 13-column layout.)

You should typically either specify your grouping or use smart layouts when building with Bootstrap, but if your use case does not fit the stacking feature you can specify neither flag and then you may then have to deal with the over-stuffed layouts as explained. 



### `--smart-layout` (also known as automatic grouping)

Smart layouts are like specified grouping but Hot Glue does the work of figuring out how many fields you want in each column. 

It will concatinate your fields into groups that will fit into the Bootstrap's 12-column grid.

The effect will be that the fields will be stacked together into nicely fit columns.

**Some people expect each field to be a column and think this looks strange.**

**If your customer is used to Excel, this feature will confuse them.**

Also, this feature will **probably not** be supported by the SORTING (not yet implemented). (You will be forced to choose between the two which I think makes sense.)

The layout builder works from right-to-left and starts with 12, the number of Bootstrap's columns.

It reserves 2 columns for the default buttons. Then +1 additional column for **each magic button** you have specified.

Then it takes 4 columns for **each downnested portal**.

If you're keeping track, that means we may have used 6 to 8 out of our Bootstrap columns already if we have buttons & portals. (With no portals and no magic buttons you have a nice even 10 columns to work with.)

If we have 2 downnested portals and only the default buttons, that uses 10 out of 12 Bootstrap columns, leaving only 2 bootstrap columns for the fields.

The layout builder takes the number of columns remaining and then distributes the feilds 'evenly' among them. However, note that order specified translates to up-to-down within the column, and then left-to-right across the columns, like so:

A D G

B E H

C F I

This is what would happen if 9 fields, specified in the order A,B,C,D,E,F,G,H,I, were distributed across 3 columns. 

(If you had a number of fields that wasn't easily divisible by the number of columns, it would leave the final column one or a few fields short of the others.)



### `--show-only=`
(separate field names by COMMA)

Any fields only the 'show-only' list will appear as non-editable on the generate form. (visible only)

IMPORTANT: By default, all fields that begin with an underscore (`_`) are automatically show-only.

I would recommend this for fields you want globally non-editable by users in your app. For example, a counter cache or other field set only by a backend mechanism.

### `--ujs_syntax=true` (Default is set automatically based on whether you have turbo-rails installed)

If you are pre-Turbo (UJS), your delete buttons will come out like this:
`data: {'confirm': 'Are you sure you want to delete....?'}`

If you are Turbo (Rails 7 or Rails 6 with proactive Turbo-Rails install), your delete button will be:
`data: {'turbo-confirm': 'Are you sure you want to delete....?'}`

If you specify the flag, you preference will be used. If you leave the flag off, Hot Glue will detect the presence of Turbo-Rails in your app. 

**WARNING**: If you created a new Rails app since October 2021 and you have the yanked turbo-rails Gems on your local machine, 
you will have some bugs with the delete buttons and also not be on the latest version of turbo-rails.

Make sure to uninstall the yanked 7.1.0 and 7.1.1 from your machine with `gem uninstall turbo-rails`
and also fix any Rails apps created since October 2021 by fixing the Gemfile. Details here:
https://stackoverflow.com/questions/70671324/new-rails-7-turbo-app-doesnt-show-the-data-turbo-confirm-alert-messages-dont-f


### `--magic-buttons` 
If you pass a list of magic buttons (separated by commas), they will appear in the button area on your list.

It will be assumed there will be corresponding bang methods on your models.

The bang (`!`) methods can respond in one of four ways:

• With true, in which case a generic success message will be shown in the flash notice (“Approved” or “Rejected” in this case)

• With false, in which case a generic error message will be shown in the flash alert (“Could not approve…”)

• With a string, which will be assumed to be a “success” case, and will be passed to the front-end in the alert notice.

• Raise an ActiveRecord exception

This means you can be a somewhat lazy about your bang methods, but keep in mind the truth operator compares boolean true NOT any object is truth. So your return object must either be actually true (boolean), or an object that is string or string-like (responds to .to_s). Want to just say it didn’t work? Return false. Want to just say it was OK? Return true. Want to say it was successful but provide a more detailed response? Return a string.

Finally, you can raise an ActiveRecord error which will also get passed to the user, but in the flash alert area

For more information see Example 5 in the Tutorial


### `--downnest`

Automatically create subviews down your object tree. This should be the name of a has_many relationship based from the current object.
You will need to build scaffolding with the same name for the related object as well. On the list view, the object you are currently building will be built with a sub-view list of the objects related from the given line.

The downnested child table (not to be confused with this object's `--nested` setting, where you are specifying this object's _parents_) is called a **child portal**. When you create a record in the child portal, the related record is automatically set to be owned by its parent (as specified by `--nested`). For an example, see the [v0.4.7 release notes](https://github.com/jasonfb/hot-glue/releases/tag/v0.4.7).

Can now be created with more space (wider) by adding a `+` to the end of the downnest name
- e.g. `--downnest=abc+,xyz`

The 'Abcs' portal will display as 5 bootstrap columns instead of the typical 4. (You may use multiple ++ to keep making it wider but the inverse with minus is not supported



## FLAGS (Options with no values)
These options (flags) also uses `--` syntax but do not take any values. Everything is assumed (default) to be false unless specified.

### `--god` or `--gd`

Use this flag to create controllers with no root authentication. You can still use an auth_identifier, which can be useful for a meta-leval authentication to the controller.

For example, FOR ADMIN CONTROLLERS ONLY, supply a auth_identifier and use `--god` flag.

In Gd mode, the objects are loaded directly from the base class (these controllers have full access)
```
def load_thing
    @thing = Thing.find(params[:id])
end

```


### `--specs-only`

Produces ONLY the controller spec file, nothing else.


### `--no-specs`

Produces all the files except the spec file.


### `--no-paginate`

Omits pagination. (All list views have pagination by default.)

### `--no-list`

Omits list action. Only makes sense to use this if want to create a view where you only want the create button or to navigate to the update screen alternative ways. (The new/create still appears, as well the edit, update & destroy actions are still created even though there is no natural way to navigate to them.)


### `--no-list-label`

Omits list LABEL itself above the list. (Do not confuse with the list heading which contains the field labels.)

(Note that on a per model basis, you can also globally omit the label or set a unique label value using
`@@table_label_singular` and `@@table_label_plural` on your model objects.)

Note that list labels may  be automatically omitted on downnested scaffolds.

### `--form-placeholder-labels` (default: false)

When set to true, fields, numbers, and text areas will have placeholder labels.
Will not apply to dates, times, datetimes, dropdowns (enums + foreign keys), or booleans.

See also setting `--form-labels-position` to control position or omit normal labels.

### `--inline-list-labels` (before, after, omit; default: omit)

Determines if field label will appear on the LIST VIEW. Note that because Hot Glue has no separate show route or page, this affects the `_show` template which is rendered as a partial from the LIST view.

Because the labels are already in the heading, this is `omit` by default. (Use with `--no-list-heading` to omit the labels in the list heading.)

Use `before` to make the labels come before or `after` to make them come after. See Version 0.5.1 release notes for an example.


### `--no-list-heading`

Omits the heading of column names that appears above the 1st row of data.

### `--no-create`

Omits new & create actions.

### `--no-delete`

Omits delete button & destroy action.

### `--big-edit`

If you do not want inline editing of your list items but instead want to fall back to full page style behavior for your edit views, use `--big-edit`. Turbo still handles the page interactions, but the user is taken to a full-screen edit page instead of an edit-in-place interaction.

### `--display-list-after-update` 

After an update-in-place normally only the edit view is swapped out for the show view of the record you just edited.

Sometimes you might want to redisplay the entire list after you make an update (for example, if your action removes that record from the result set).

To do this, use flag `--display-list-after-update`. The update will behave like delete and re-fetch all the records in the result and tell Turbo to swap out the entire list.





## Automatic Base Controller

HotGlue will copy a file named base_controller.rb to the same folder where it tries to create any controller, unless such a file exists there already.

The created controller will always have this base controller as its subclass. You are encouraged to implement functionality common to the *namespace* (shared between the controllers in the namespace) using this technique.

## Special Table Labels

If your object is very wordy (like MyGreatHook) and you want it to display in the UI as something shorter,
add `@@table_label_plural = "Hooks"` and `@@table_label_singular = "Hook"`. 

Hot Glue will use this as the **list heading** and **New record label**, respectively. This affects only the UI only.

You can also set these to `nil` to omit the labels completely. 

Child portals have the headings omitted automatically (there is a heading identifying them already on the parent view where they get included), or you can use the `--no-list-heading` on any specific build. 


## Field Types Supported

- Integers that don't end with `_id`: displayed as input fields with type="number"
- Foreign keys: Integers that do end with `_id` will be treated automatically as associations. You should have a Rails association defined. (Hot Glue will warn you if it can't find one.)
  - Note:  if your foreign key has a nonusual class name, it should be using the `class_name:` in the model definition
- String: displayed as small input box 
- Text: displayed as large textarea
- Float: displayed as input box
- Datetime: displayed as HTML5 datetime picker
- Date: displayed as HTML5 date picker
- Time: displayed as HTML5 time picker
- Boolean: displayed radio buttons yes/ no
- Enum - displayed as a drop-down list (defined the enum values on your model). 
  - For Rails 6 see https://jasonfleetwoodboldt.com/courses/stepping-up-rails/enumerated-types-in-rails-and-postgres/
  - AFAIK, you must specify the enum definition both in your model and also in your database migration for both Rails 6 + Rails 7


# VERSION HISTORY

#### 2022-11-24 - v0.5.3 - New testing paradigm & removes license requirements

New testing paradigm
Code cleanup
Testing on CircleCI
License check has been removed (Hot Glue is now free to use for hobbyists and individuals. Business licenses are still available at https://heliosdev.shop/hot-glue-license)


#### 2022-03-23 - v0.5.2 - Hawked Foreign Keys

 - You can now protect your foreign keys from malicious input and also restrict the scope of drop downs to show only records with the specified access control restriction.
 - [Example #3](https://jfb.teachable.com/courses/hot-glue-in-depth-tutorial/lectures/38584014) in the Hot Glue Tutorial shows you how to use the hawk to limit the scope to the logged in user.
 - [Example #4](https://jfb.teachable.com/courses/hot-glue-in-depth-tutorial/lectures/38787505) in the Hot Glue Tutorial shows how to hawk to a non-usual scope, the inverse of the current user's belongs_to (that is, hawk the scope to X where current_user `belongs_to :x`)
 

#### 2022-03-12  - v0.5.1 - Inline List Labels

`--inline-list-labels` (default: `after`; options are **before**, **after**, and **omit**)

Determines if field label will appear on the LIST VIEW. Note that because Hot Glue has no separate show route or page, this affects the `_show` template which is rendered as a partial from the LIST view.

Because the labels are already in the heading, this `omit` by default. (Use with `--no-list-heading` to omit the labels in the list heading.)

Use `before` to make the labels come before or `after` to make them come after. See Version 0.5.1 release notes for an example.

#### 2022-03-06 - v0.5.0 - Label options before or after or with placeholder labels
   `--form-labels-position` (default: `after`; options are **before**, **after**, and **omit**)
By default, form labels appear after the form inputs. To make them appear before or omit them, use this flag.

   `--form-placeholder-labels` (default: false)

When this flag is set, fields, numbers, and text areas will have placeholder labels.
Will not apply to dates, times, datetimes, dropdowns (enums + foreign keys), or booleans.

For example see the [release notes](https://github.com/jasonfb/hot-glue/releases/tag/v0.5.0)


#### 2022-02-14 - v0.4.9
• Fixed issue building models with namespaced class names (e.g. `Fruits::Apple` and `Fruits::Bannana`). 
  You can now build against these kinds of models natively (be sure to pass the full model name, with double-colon syntax). 

• Also fixes issues when associations themselves were namespaced models.

• The N+1 Killer (!!!) 
    - N+1 queries for _any association_ built by the list are now automagically killed by the list controllers.
    - Thanks to the work done back in Rails 5.2, Rails smartly uses either two queries to glob up the data OR one query with a LEFT OUTER JOIN if that's faster. You don't have to think about it. **Thanks Rails 5.2!**
    - Hot Glue now adds `.includes(...)` if it is including an association when it loads the list view to eliminate the N+1s
    - Bullet is still the best way to identify, find, & fix your N+1 queries is still highly recommended. https://github.com/flyerhzm/bullet 

• Downnest children (portals) can now be created with more space (made wider) by adding one or more `+` to the end of the downnest name, denoting add 1 bootstrap column.
    - e.g. `--downnest=abc+,xyz`

    The "Abc" portal will take up 5 bootstrap columns and the Xyz portal will take up 4 columns. (++ to indicate 6, `+++` for 7, etc)

• Now that you can expand the downnest child portal width, you can easily give them too much width taking up more than 12 bootstrap columns. 
  The builder stops you from building if you have taken up too many bootstrap columns, are in _either_ **Smart Layout mode** or **Specified Grouping mode**.
  However, this check is not in place if you are in neither mode, in which case you should watch out for building more than 12 bootstrap columns.

• To give a special label to a model, add `@@table_label_plural = "The Things"` and `@@table_label_singular = "The Thing"`. 
  This model will now have a list heading of "The Things" instead of its usual name. 
  For 'create buttons' and the 'New' screen, the builder will use the singular setting. 
  This affects all builds against that model and affects the UI (display) only. 
  All route names, table names, and variables are unaffected by this.

• You can also use `@@table_label_plural = nil` to set these tables to **omit** the label headings, or use the new flag...

• `--no-list-heading` (defaults to false but note several conditions when list headings are now hidden)

Omits the list heading. Note that the listing heading is omitted: 
1) if there is no list, 
2) if you set the `--no-list-heading` flag, 
3) if the model has `@@table_label_plural = nil`, or 
4) if you are constructing a nested child portal with only non-optionalized parents. 

#### 2022-02-09 - v0.4.8.1 - Issue with Installer for v0.4.8
    - There was an issue for the installer for v0.4.8. This new version v0.4.8.1 correts it.


#### 2022-02-07 - v0.4.8 Optionalized Nested Parents
    - optionalized nested parents. to use add `~` in front of any nested parameter you want to make optional
    

#### 2022-01-26 - v0.4.7 `--nest` has been renamed to `--nested`; please use `--nested` moving forward
  - `--alt-controller-name` feature from the last release has been removed, I have something better coming soon
  - significant improvements to how child portals are handled, including setting the owner (parent) object when creating new records from a child portal
  - improvements to how 'self-auth' is handled, i.e., when a controller is built using an authentication identifier (e.g. `current_user`) that is the same as the controller's object
  - note that when building a self-auth controller, the list view still behaves as-if it is a list but controller only has access to the auth object (e.g. `current_user`). You would really only need this for the edge case of a user updating their own record, or, as in the example, to use as the starting point for building the child portals.  
  - another edge case in here that has been fixed involved creating a 'no field' form-- in the example, invoices are created using the "new" button and "save" button, even though the form has no editable fields for the user to input. In these edge cases, an invisible form field is inserted to make the form submission work correctly. This only happens for an action that has no inputable fields. 
  - cleaner code for the `_form` output and also the `controller` output 

#### 2022-01-23 - v0.4.6 -  `--no-list-labels` (flag; defaults false)
(additional features in this release have been subsequently removed)

#### 2022-01-11 - v0.4.5 - buttons on smart layouts take up 1 bootstrap column each; fixes confirmation alert for delete buttons

#### 2022-01-01 - v0.4.3 and 0.4.4 - adding fully email-based license, no activation codes required.

#### 2022-12-30 - v0.4.2 -- Smart layouts introduced

#### 2021-12-15 - v0.4.1

#### 2021-12-12 - v0.4.0

#### 2021-12-12 - v0.3.9 - Magic Buttons

#### 2021-12-11 - v0.3.5 - Downnesting


#### 2021-11-27 - v0.2.9E   (experimental)
                     - Downnesting
                     - Adds spec coverage support for enums
                     - Several more fixes; this is preparation for forthcoming release.
                     - Some parts still experimental. Use with caution. 

#### 2021-10-11 - v0.2.6 - many additional automatic fixes for default Rails installation 6 or 7 for the generate hot_glue:install command

#### 2021-10-10 - v0.2.5 - this version is all about developer happyness:
                            - significant fixes for the behavioral (system) specs. they now create new & update interactions
                            for (almost) all field types
                            - the install generator now checks your layouts/application.html.erb for `render partial: 'layouts/flash_messages' ` and adds it if it isn't there already
                            - the install generator also checks your spec/rails_helper for `config.include FactoryBot::Syntax::Methods` and adds it at the top of the Rspec configure block if it isn't there

#### 2021-10-07 - v0.2.4 - removes erroneous icons display in delete buttos (these don't work inside of button_to);
                            - adds support for ENUM types direclty on your field types
                            - you  must use activerecord-pgenum
                            - see my blog post at https://jasonfleetwoodboldt.com/courses/stepping-up-rails/enumerated-types-in-rails-and-postgres/

#### 2021-09-30 - v0.2.3 - fixes ERB output for show-only fields; fixes flash_notices for erb or haml; adds @stimulus_syntax flag for delete confirmations with stimulus

#### 2021-09-27 - v0.2.2 - Fixes some issues with related fields; unlocks Rails 7 in Gemspec file

#### 2021-09-20 - v0.2.1 - Fixes nesting behavior when using gd option

#### 2021-09-06 - v0.2.0 - ERB or HAML; use the option --markup=erb or --markup=haml (default is now erb)

#### 2021-06-28 - v0.1.2 - fixes problem with namespaces on path helpers

#### 2021-05-09 (yanked) - v0.1.1 -  add cancellation buttons

#### 2021-04-28 - v0.1.0 - Very pleased to introduce full behavior specs, found in specs/system/, generated by default on all build code; also many fixes involving nesting and authentication"

#### 2021-03-24 - v0.0.9 - fixes in the automatic field label detection; cleans up junk in spec output

#### 2021-03-21 - v0.0.8 - show only flag; more specific spec coverage in generator spec

#### 2021-03-20 - v0.0.7 - adds lots of spec coverage; cleans up generated cruft code on each run;  adds no-delete, no-create; a working --big-edit with basic data-turbo false to disable inline editing

#### 2021-03-06 - v0.0.6 - internal specs test the error catches and cover basic code generation (dummy testing only)

#### 2021-03-01 - v0.0.5 - Validation magic; refactors the options to the correct Rails::Generators syntax

#### 2021-02-27 - v0.0.3 - several fixes for namespaces; adds pagination; adds exclude list to fields

#### 2021-02-25 - v0.0.2 - bootstrapy

#### 2021-02-24 - v0.0.1 - first proof of concept release -- basic CRUD works


# HOW THIS GEM IS TESTED

The gem is tested against both generated specs and internal specs. The generated specs are regenerated with the test run, whereas the internal specs live as artifacts in the codebase as you would normally expected specs would.

The generated specs are created with a small set of 'starter seeds' that exercise the gem's featureset. You can examine the setup easily by looking at the contents of `script/test`

• To setup for testing, start with
```
sudo gem install rails
sudo gem install rspec
```

```
sudo gem install minitest -v 5.1.0
```

Unfortunately because of the wrapped nature of the specs, these must be run from globally installed Rubies.

• Once you've done the above, run `script/test`

This runs both the **generated specs** and also the **internal specs**. Examine this file for details.

To run only the internal specs, use 

`COVERGE=on rspec spec`

Internal Test coverage as of 2022-03-23 (v0.5.2)

![HG 84 89 coverage report](https://user-images.githubusercontent.com/59002/159719583-a956cfb3-1797-4186-b32c-237ed19e8e2b.png)

