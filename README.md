
![Integrated Logo design-639x264](https://user-images.githubusercontent.com/59002/189544688-c1a8226f-9dbd-4758-bc0c-712fc2754cbd.png)

Hot Glue is a Rails scaffold builder for the Turbo era. It is an evolution of the admin-interface style scaffolding systems of the 2010s ([activeadmin](https://github.com/activeadmin/activeadmin), [rails_admin](https://github.com/sferik/rails_admin), and [active_scaffold](https://github.com/activescaffold/active_scaffold)).

Using Turbo-Rails and Hotwire (default in Rails 7) you get a lightning-fast out-of-the-box CRUD-building experience.

Every page displays only a list view: new and edit operations happen as 'edit-in-place,' so the user never leaves the page. Because all page navigation is Turbo's responsibility, everything plugs & plays nicely into a Turbo-backed Rails app.

Alternatively, you can use this tool to create a Turbo-backed *section* of your Rails app -- such as an admin interface -- while still treating the rest of the Rails app as an API or building out other features by hand.

It will read your relationships and field types to generate your code for you, leaving you with a 'sourdough starter' to work from. If you modify the generated code, you're on your own if you want to preserve your changes and also re-generate scaffolding after adding fields.

By default, it generates code that gives users full control over objects they 'own' and by default it spits out functionality giving access to all fields. (Handily, Hot Glue leaves the command you used in a comment at the top of your generated controller so you can regenerate it again in the future.)

Alternatively, refinements allow you to scope records using custom access control or Pundit. Hot Glue scaffold comes with pagination by default and now has an option to add searching too.

Hot Glue generates quick and dirty functionality. It lets you be crafty. However, like with a real glue gun, please be sure to use it with caution.

* Build plug-and-play scaffolding mixing generated ERB with the power of Hotwire and Turbo-Rails
* Everything edits-in-place (unless you use `--big-edit`)
* Automatically reads your models (make them, add relationships, **and** migrate your database before building your scaffolding!)
* Excellent for CREATE-READ-UPDATE-DELETE (CRUD), lists with pagination
* Great for prototyping, but you should learn Rails fundamentals first.
* 'Packaged' with Devise, Kaminari, Rspec
* Create system specs automatically along with the generated code.
* Nest your routes model-by-model for built-in poor man's authentication.
* Throw the scaffolding away when your app is ready to graduate to its next phase.

How is it different than Rails scaffolding?

Although inspired by the Rails scaffold generators (built-in to Rails), Hot Glue does something similiar but has made opinionated decisions that deviate from the normal Rails scaffold: 

1. The Hot Glue scaffolds are complete packages and are pre-optimized for 'edit-in-place' so that new and edit operations happen in-page smoothly. 
2. Hot Glue does not create your models along with your scaffolding. Instead, create them first using `rails generate model X`
3. Hot Glue *reads* the fields on your database *and* the relationships defined on your models. Unlike the Rails scaffolding you must add relationships and migrate your DB before building your scaffolding.
4. Hot Glue has many more features for building layouts quickly, like choosing which fields to include or exclude and how to lay them out on the page, searching and scoping, related portals and nested sets, and applying modifiers (like currency or date format) and more. 

Other than the opinionated differences and additional features, Hot Glue produces code that is fundamentally very similiar and works consistent with the Rails 7 Hotwire & Turbo paradigms.

# Get Hot Glue

## [GET THE COURSE TODAY](https://school.jfbcodes.com/8188/?utm_source=github.com&utm_campaign=github_hot_glue_readme_page) **only $60 USD!**


---
---
## HOW EASY?

```
rails generate hot_glue:scaffold Thing 
```

Generate a quick scaffold to manage a table called `pronouns`
![hot-glue-3](https://user-images.githubusercontent.com/59002/116405509-bdee2f00-a7fd-11eb-9723-4c6e22f81bd3.gif)

Instantly get a simple CRUD interface

![hot-glue-4](https://user-images.githubusercontent.com/59002/116405517-c2b2e300-a7fd-11eb-8423-d43e3afc9fa6.gif)


# Getting Started Video
[Hot Glue Getting Started (JSBundling)](https://www.youtube.com/watch?v=bzpXOhBkiDk)

_If you are on Rails 6, see [LEGACY SETUP FOR RAILS 6](https://github.com/jasonfb/hot-glue/README2.md) and complete those steps FIRST._

## The Super-Quick Setup
https://jasonfleetwoodboldt.com/courses/stepping-up-rails/jason-fleetwood-boldts-rails-cookbook/hot-glue-quick-install-mega-script/
Copy & paste the whole code block into your terminal.
Remember, there is a small "Copy" button at the top-right of the code block.
Be sure to use your Node + Ruby version managers to switch into the Node & Ruby versions **before running the quick script**. 


For more of a step-by-step, see the full cookbook at:
https://jasonfleetwoodboldt.com/courses/stepping-up-rails/jason-fleetwood-boldts-rails-cookbook/

These are the sections you need, you can ignore any others:

* Section 1A for a new JS Bundling app, then skip down to 
* Section 2B: Rspec + Friends
* Section 2B-Capy: Capybara for Rspec, then skip down to 
* Section 3 for a welcome controller
( you can skip everything in Section 4 )
* Section 5 for debugging tools
* _Section 6 is the Hot Glue installer itself_ (this gem) - for Bootstrap, choose section 6A
* Section 7A to install Bootstrap along with CSSBundling
* Section 8 to set up Devise if you want authentication. (See how Hot Glue interacts with Devise below.)

If you do this through the quick setup above, you can then skip down past the next section to the "HOT GLUE DOCS" below. 

## Step-By-Step Setup

### 1. RAILS NEW
To understand the options for `rails new`, see [this post](https://jasonfleetwoodboldt.com/courses/rails-7-crash-course/rails-7-bootstrap/)

It is important that you know what kind of app you are creating (Importmap, JSBundling, or Shakapacker) because there are specific differences in how you will work with them. (Hot Glue is compatible with all 3 paradigms, but if you don't take the time to understand the setup, you will be confused as to why things aren't working.)

To run Turbo (which Hot Glue requires), you must either (1) be running an ImportMap-Rails app, or (2) be running a Node-compiled app using any of JSBundling, Shakapacker, or its alternatives.

(1) To use ImportMap Rails, start with
`rails new MyGreatApp`

(For full instructions to install Bootstrap with Importmap, check out [these instructions](https://jasonfleetwoodboldt.com/courses/stepping-up-rails/importmap-rails-with-bootstrap-sprockets-stimulus-and-turbo-long-tutorial/))

(2) To use JSBundling, start with
`rails new MyGreatApp --javascript=esbuild`


**If using JSBundling, make sure to use the new `./bin/dev` to start your server instead of the old `rails server` or else your Turbo interactions will not work correctly.**
(If you want Bootstrap for a JSBundling app, install it following [these instructions](https://jasonfleetwoodboldt.com/courses/stepping-up-rails/rails-7-up-running-with-jsbundling-esbuild-stimulus-turbo-bootstrap-circleci/))

(3) To use Shakapacker, start with `rails new MyGreatApp --skip-javascript` and [see this post](https://jasonfleetwoodboldt.com/courses/react-heart-rails/rails-7-shakapacker-and-reactonrails-quick-setup-part-1/)

(For the old method of installing Bootstrap [see this post](https://jasonfleetwoodboldt.com/courses/stepping-up-rails/rails-7-bootstrap/))

(Remember, for Rails 6 you must go through the [LEGACY SETUP FOR RAILS 6](https://github.com/jasonfb/hot-glue/blob/main/README2.md) before continuing.)


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

### 3. CSS Bundling Rails (optional)

```
bundle add cssbundling-rails
./bin/rails css:install:bootstrap
```



### 4. HOTGLUE INSTALLER
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
`./bin/rails generate hot_glue:install --markup=erb --layout=bootstrap`

#### Example installing using Hot Glue layout and the 'like_mountain_view' (Gmail-inspired) theme:
`rails generate hot_glue:install --markup=erb --layout=hotglue --theme=like_mountain_view`

The Hot Glue installer did several things for you in this step. Examine the git diffs or see 'Hot Glue Installer Notes' below.

### 4. Devise
(If you are on Rails 6, you must do ALL of the steps in the Legacy Setup steps. Be sure not to skip **Legacy Step #5** below)
https://github.com/jasonfb/hot-glue/blob/main/README2.md

You MUST run the installer FIRST or else you will put your app into a non-workable state:
```
./bin/rails generate devise:install
```

IMPORTANT: Follow the instructions the Devise installer gives you, *Except Step 3*, you can skip this step:
```
 3. Ensure you have flash messages in app/views/layouts/application.html.erb.
     For example:

       <p class="notice"><%= notice %></p>
       <p class="alert"><%= alert %></p>

```

Be sure to create primary auth model with:

`./bin/rails generate devise User name:string`

Remember, you don't need to tell Devise that your User has an email, an encrypted password, a reset token, and a 'remember me' flag to let the user stay logged in.

Those features come by default with Devise, and you'll find the fields for them in the newly generated migration file. 

In this example above, you are creating all of those fields along with a simple 'name' (string) field for your User table.

Devise 4.9.0 is now fully compatible with Rails 7.

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

Remember: Use `bin/rails generate model Thing` to generate models. Then add `has_many`, `belongs_to`, and _migrate your database_ before building the scaffold with Hot Glue.

You will also need every Rails model to contain _either_ a database column _or_ an object-level method named one of these five things:
`name`
`to_label`
`full_name`
`display_name`
`email`

If your database doesn't contain one of these five, add a method to your model using `def to_label`. This will be used as the default label for the object throughout the Hot Glue build system. 

## First Argument
(no double slash)

TitleCase class name of the thing you want to build a scaffolding for.

```
./bin/rails generate hot_glue:scaffold Thing
```

(note: Your `Thing` object must `belong_to` an authenticated `User` or alternatively you must create a Gd controller, see below.)

## Options With Arguments

All options begin with two dashes (`--`) and a followed by an `=` and a value

### `--namespace=`

pass `--namespace=` as an option to denote a namespace to apply to the Rails path helpers


`./bin/rails generate hot_glue:scaffold Thing --namespace=dashboard`

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

`./bin/rails generate hot_glue:scaffold Invoice`

`./bin/rails generate hot_glue:scaffold Line --nested=invoice`


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

`./bin/rails generate hot_glue:scaffold Invoice`

`./bin/rails generate hot_glue:scaffold Line --nested=invoice`

`./bin/rails generate hot_glue:scaffold Charge --nested=invoice/line`



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
./bin/rails generate hot_glue:scaffold User --namespace=admin --gd
./bin/rails generate hot_glue:scaffold Invoice --namespace=admin --gd --nested=~users
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

`./bin/rails generate hot_glue:scaffold Thing --auth=current_account`

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


`./bin/rails generate hot_glue:scaffold Thing --auth=current_account --auth_identifier=login`

 
In this example, the controller produced with:
```
   before_action :authenticate_login!
```
However, the object graph anchors would continue to start from current_account. That is,
```
@thing = current_account.things.find(params[:id])
```

Use empty string to **turn this method off**:
 
`./bin/rails generate hot_glue:scaffold Thing --auth=current_account --auth_identifier=''`

In this case a controller would be generated that would have NO before_action to authenticate the account, but it would still treat the current_account as the auth root for the purpose of loading the objects.

Please note that this example would produce non-functional code, so you would need to manually fix your controllers to make sure `current_account` is available to the controller.


### `--hawk=`

Hawk a foreign key that is not the object's owner to within a specified scope. 

Assuming a Pet belong_to a :human, when building an Appointments scaffold,
you can hawk the `pet_id` to the current human's pets. (Whoever is the authentication object.)

The hawk has two forms: a short-form (`--hawk=key`) and long form (`--hawk=key{scope})

The short form looks like this. It presumes there is a 'pets' association from `current_user`
`--hawk=pet_id`

(The long form equivalent of this would be `--hawk=pet_id{current_user.pets}`)

This is covered in [Example #3 in the Hot Glue Tutorial](https://school.jfbcodes.com/8188)

To hawk to a scope that is not the currently authenticated user, use the long form with `{...}` 
to specify the scope. Be sure to note to add the association name itself, like `users`: 

`--hawk=user_id{current_user.family.users}`

This would hawk the Appointment's `user_id` key to any users who are within the scope of the 
current_user's has_many association (so, for any other "my" family, would be `current_user.family.users`). 

This is covered in [Example #4 in the Hot Glue Tutorial](https://school.jfbcodes.com/8188)


### `--plural=`

You don't need this if the pluralized version is just + "s" of the singular version.
Only use for non-standard plurlizations, and be sure to pass it as TitleCase (as if you pluralized the model name which is non-standard for Rails)

An better alternative is to define the non-standard plurlizations globally in your app, which Hot Glue will respect.

Make a file at `config/initializers/inflections.rb`
 
Add new inflection rules using the following format:
```
ActiveSupport::Inflector.inflections do |inflect|
    inflect.irregular 'clothing', 'clothes'
    inflect.irregular 'human', 'humans'  
end
```




### `--exclude=`
(separate field names by COMMA)

By default, all fields are included unless they are on the default exclude list. (The default exclude list is `id`, `created_at`, `updated_at`, `encrypted_password`, `reset_password_token`, `reset_password_sent_at`, `remember_created_at`, `confirmation_token`, `confirmed_at`, `confirmation_sent_at`, `unconfirmed_email`.)

If you specify any exclude list, those excluded **and** the default exclude list will be excluded. (If you need any of the fields on the default exclude list, you must use `--include` instead.)


`./bin/rails generate hot_glue:scaffold Account --exclude=password`


### `--include=`
Separate field names by COMMA

If you specify an include list, it will be treated as a whitelist: no fields will be included unless specified on the include list.

`./bin/rails generate hot_glue:scaffold Account --include=first_name,last_name,company_name,created_at,kyc_verified_at`

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



### `--modify=field1{...},field2{...}`


You can apply modification to the viewable (non-edit) display of field using the `--modify` switch.

The syntax is `--modify=cost{$},price{$}`

Here, the `cost` and `price` fields will be displayed as wrapped in `number_to_currency()` when displayed on the list view and when displayed as show-only.

You can also use a binary modifier, which can apply to booleans, datetimes, times, dates or anything else. When using the binary modify, a specific value is displayed if the field is truthy and another one is display if the field is falsy.
You specify it using a pipe | character like so:

`--modify=paid_at{paid|unpaid}`

here, even though `paid_at` is a datetime field, it will display as-if it is a binary -- showing either the truthy 
label or the falsy label depending on if `paid_at` is or is not null in the database.  
For all fields except booleans, this affects only the viewable output — 
what you see on the list page and on the edit page for show-only fields.  
For booleans shown as radio buttons, it affects those outputs as well as the normal view output.
For booleans shown as checkboxes or switches, it affects only the view output as the truthy and falsy labels are not displays in editbale view.

You will need to separately specify them as show-only if you want them to be non-editable.

Notice that each modifiers can be used with specific field types. 

| user modifier                 | what it does                                                                                                                                                     | Field types                       |   |   |
|-------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------|---|---|
| $                             | wraps output in `number_to_currency()`                                                                                                                           | floats and integers               |   |   |
| (truthy label)\|(falsy label) | specify a binary switch with a pipe (\|) character if the value is truthy, it will display as "truthy label" if the value is falsy, it will display as "falsy label" | booleans, datetimes, dates, times |   |    |
| partials                      | applies to enums only, you must have a partial whose name matches each enum type                                                                                 | enums only                        |   |   |
| tinymce                       | applies to text fields only, be sure to setup TineMCE globally                                                                                                   | text fields only                  |    |   |
| typeahead                     | turns a foreign key (only) into a searchable typeahead field                                                                                                     | foreign keys only                 |   |   |

Except for "(truthy label)" and "(falsy label)" which use the special syntax, use the modifier _exactly_ as it is named.

### `--pundit`
If you enable Pundit, your controllers will look for a Policy that matches the name of the thing being built.

**Realtime Field-level Access**
Hot Glue gives you automatic field level access control if you create `*_able?` methods for each field you'd like to control on your Pundit policy.

(Although this is not what Pundit recommends for field level access control, it has been implemented this way to provide field-by-field user feedback to the user shown in red just like Rails validation errors are currently shown. A user having access to input text into a field they shouldn't have access to is *only hypothetical*, because the Hot Glue will correctly show the the user connect edit was view-only anyway, making unallowed entry only something that could be achieved through a mistake or hacking. Nevertheless, rest assured that if there was a input mistake-- like a user having a field editable when it shouldn't be, if you implement your backend policy correctly with an `update?` method guards against the disallowed input, your user will show an error message and the record will not be updated.)

The `*_able?` method should return true or false depending on whether or not the field can be edited. No distinction is made between the `new` and `edit` contexts. You may check if the record is new using `new_record?`.


**The `*_able?` method is used by Hot Glue only on the new and edit actions. You must incorporate it into the policy's `update?` method as in the example, or else no guard will check prevent the user doesn't pass a value to input it anyway.**


Add one `*_able?` method to the policy for each field you want to allow field-level access control. 

Replace `*` with the name of the field you want under access control. Remember to include `_id` for foreign keys. You do not need it for any field you don't want under access control.

When the method returns true, the field will be displayed to the user (and allowed) for editing. 
When the method returns false, the field will be displayed as read-only (viewable) to the user.

Important: These special fields determine *only* display behavior (new and edit), not create and update. 

For create & update field-level access control, you must also implement the `update?` method on the Policy. Notice how in the example policy below, the `update?` method uses the `name_able?` method when it is checking if the name field can be updated, tying the feature together.

You can set Pundit to be enabled globally on the whole project for every build in `config/hot_glue.yml` (then you can leave off the `--pundit` flag from the scaffold command)
`:pundit_default:` (all builds in that project will use Pundit)


Here's an example `ThingPolicy` that would allow **editing the name field** only if:
• the current user is an admin
• the sent_at date is nil (meaning it has not been sent yet)

For your policies, copy the `initialize` method of both the outer class (`ThingPolicy`) and the inner class (`Scope`) exactly as shown below.


```
class ThingPolicy < ApplicationPolicy
  def initialize(user, record)
    @user = user
    @record = record
  end
  
  def name_able?
    @record.sent_at.nil?
  end
  
  def update?
     if !@user.is_admin?
       return false
    elsif record.name_changed? && !name_able?
      record.errors.add(:name, "cannot be changed.")
      return false
    else
      return true
    end
  end
  
  class Scope < Scope
    attr_reader :user, :scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end
  end
end
```


Because Hot Glue detects the `*_able?` methods at build time, if you add them to your policy, you will have to rebuild your scaffold.


### `--show-only=`
(separate field names by COMMA)

• Make this field appear as viewable only all actions. (visible only)
• When set on this list, it will override any Pundit policy even when Pundit would otherwise allow the access.

IMPORTANT: By default, all fields that begin with an underscore (`_`) are automatically show-only.

This is for fields you want globally non-editable by users in your app. For example, a counter cache or other field set only by a backend mechanism.


### `--update-show-only`
(separate field names by COMMA)

• Make this field appear as viewable only for the edit action (and not allowed in the update action). 
• When set on this list, it will override any Pundit policy for edit/update actions even when Pundit would otherwise allow the access.


Note that Hot Glue still generates a singular partial (`_form`) for both actions, but your form will now contain statements like:

```
 <% if action_name == 'edit' %>
    <%= xyz.name %><
 <% else %>
    <%= f.text_field :name %>
 <% end %>
```

This works for both regular fields, association fields.


When mixing the show only, update show only, and Pundit features, notice that the show only + update show only will act to override whatever the policy might say.

Remember, the show only list is specified using `--show-only` and the update show only list is specified using `--update-show-only`.

'Viewable' means it displays as view-only (not editable) even on the form. In this context, 'viewable' means 'read-only'. It does not mean 'visible'. 

That's because when the field is **not viewable**, then it is editable or inputable. This may seem counter-intuitive for a standard interpretation of the word 'viewable,' but consider that Hot Glue has been carefully designed this way. If you do not want the field to appear at all, then you simply remove it using the exclude list or don't specify it in your include list. If the field is being built at all, Hot Glue assumes your users want to see or edit it. Other special cases are beyond the scope of Hot Glue but can easily be added using direct customization of the code. 

Without Pundit:
|                                          | on new screen | on edit screen |
|------------------------------------------|---------------|----------------|
| for a field on the show only list        | viewable      | viewable       |
| for a field on the update show only list | inputable     | viewable       |
| for all other fields                     | inputable     | inputable      |


With Pundit:
|                                          | on new screen | on edit screen |
|------------------------------------------|---------------|----------------|
| for a field on the show only list        | viewable      | viewable       |
| for a field on the update show only list | check policy  | viewable       |
| for all other fields                     | check policy  | check policy   |
|                                          |               |                |

Remember, if there's a corresponding `*_able?` method on the policy, it will be used to determine if the field is **editable** or not in the cases where 'check policy' is above.
(where `*` is the name of your field)

As shown in the method `name_able?` of the example ThingPolicy above, if this field on your policy returns true, the field will be editable. If it returns false, the field will be viewable (read-only).


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

Finally, you can raise an ActiveRecord error which will also get passed to the user in the flash alert area.

For more information see [Example 5 in the Tutorial](https://school.jfbcodes.com/8188)


### `--downnest`

Automatically create subviews down your object tree. This should be the name of a has_many relationship based from the current object.
You will need to build scaffolding with the same name for the related object as well. On the list view, the object you are currently building will be built with a sub-view list of the objects related from the given line.

The downnested child table (not to be confused with this object's `--nested` setting, where you are specifying this object's _parents_) is called a **child portal**. When you create a record in the child portal, the related record is automatically set to be owned by its parent (as specified by `--nested`). For an example, see the [v0.4.7 release notes](https://github.com/jasonfb/hot-glue/releases/tag/v0.4.7).

Can now be created with more space (wider) by adding a `+` to the end of the downnest name
- e.g. `--downnest=abc+,xyz`

The 'Abcs' portal will display as 5 bootstrap columns instead of the typical 4. (You may use multiple ++ to keep making it wider but the inverse with minus is not supported

### `--stacked-downnesting`

This puts the downnested portals on top of one another (stacked top to bottom) instead of side-by-side (left to right). This is useful if you have a lot of downnested portals and you want to keep the page from getting too wide.


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

### `--button-icons` (default is no icons)
You can specify this either as builder flag or as a config setting (in `config/hot_glue.yml`)
Use `font-awesome` for Font Awesome or `none` for no icons.


### `--specs-only`

Produces ONLY the controller spec file, nothing else.


### `--no-specs`

Produces all the files except the spec file.


### `--no-paginate` (default: false)

Omits pagination. (All list views have pagination by default.)

### `--paginate-per-page-selector` (default: false)

Show a small drop-down below the list to let the user choose 10, 25, or 100 results per page.


### `--no-list`

Omits list action. Only makes sense to use this if want to create a view where you only want the create button or to navigate to the update screen alternative ways. (The new/create still appears, as well the edit, update & destroy actions are still created even though there is no natural way to navigate to them.)



### `--no-create`

Omits new & create actions.

### `--no-delete`

Omits delete button & destroy action.

### `--no-controller`

Omits controller.

### `--no-list`

Omits list views. 

### `--big-edit`

If you do not want inline editing of your list items but instead want to fall back to full page style behavior for your edit views, use `--big-edit`. Turbo still handles the page interactions, but the user is taken to a full-screen edit page instead of an edit-in-place interaction.

When using `--big-edit`, any downnested portals will be displayed on the edit page instead of on the list page. 

### `--display-list-after-update`

After an update-in-place normally only the edit view is swapped out for the show view of the record you just edited.

Sometimes you might want to redisplay the entire list after you make an update (for example, if your action removes that record from the result set).

To do this, use flag `--display-list-after-update`. The update will behave like delete and re-fetch all the records in the result and tell Turbo to swap out the entire list.

### `--with-turbo-streams`

If and only if you specify `--with-turbo-streams`, your views will contain `turbo_stream_from` directives. Whereas your views will always contain `turbo_frame_tags` (whether or not this flag is specified) and will use the Turbo stream replacement mechanism for non-idempotent actions (create & update). This flag just brings the magic of live-reload to the scaffold interfaces themselves.

**_To test_**: Open the same interface in two separate browser windows. Make an edit in one window and watch your edit appear in the other window instantly.

This happens using two interconnected mechanisms:

1) by default, all Hot Glue scaffold is wrapped in `turbo_frame_tag`s. The id of these tags is your namespace + the Rails dom_id(...). That means all Hot Glue scaffold is namespaced to the namespaces you use and won't collide with other turbo_frame_tag you might be using elsewhere

2) by appending **model callbacks**, we can automatically broadcast updates to the users who are using the Hot Glue scaffold. The model callbacks (after_update_commit and after_destroy_commit) get appended automatically to the top of your model file. Each model callback targets the scaffold being built (so just this scaffold), using its namespace, and renders the line partial (or destroys the content in the case of delete) from the scaffolding.

please note that *creating* and *deleting* do not yet have a full & complete implementation: Your pages won't re-render the pages being viewed cross-peer (that is, between two users using the app at the same time) if the insertion or deletion causes the pagination to be off for another user.


### `--related-sets`

Used to show a checkbox set of related records. The relationship should be a `has_and_belongs_to_many` or a `has_many through:` from the object being built.

Consider the classic example of three tables: users, user_roles, and roles

User `has_many :user_roles`; UserRole `belongs_to :user` and `belongs_to :role`; and Role `has_many :user_roles` and `has_many :user, through: :user_roles`

We'll generate a scaffold to edit the users table. A checkbox set of related roles will also appear to allow editing of roles. (In this example, the only field to be edited is the email field.)

```
rails generate hot_glue:scaffold User --related-sets=roles --include=email,roles --gd
```

Note this leaves open a privileged escalation attack (a security vulnerability).

To fix this, you'll need to use Pundit with special syntax designed for this purpose. Please see [Example #17 in the Hot Glue Tutorial](https://school.jfbcodes.com/8188)


## "Thing" Label

Note that on a per model basis, you can also globally omit the label or set a unique label value using
`@@table_label_singular` and `@@table_label_plural` on your model objects.

You have three options to specify labels explicitly with a string, and 1 option to specify a global name for which the words "Delete ___" and "New ___" will be added.

If no `--label` is specified, it will be inferred to be the Capitalized version of the name of the thing you are building, with spaces for two or more words.

### `--label`

The general name of the thing, will be applied as "New ___" for the new button & form. Will be *pluralized* for list label heading, so if the word has a non-standard pluralization, be sure to specify it in `config/inflictions.rb`

If you specify anything explicitly, it will be used.
If not, a specification that exists as `@@tabel_label_singular` from the Model will be used.
If this does not exist, the Titleized (capitalized) version of the model name. 

### `--list-label-heading`
The plural of the list of things at the top of the list.
If not, a specification that exists as `@@tabel_label_plural` from the Model will be used.
If this does not exist, the UPCASE (all-uppercase) version of the model name.

### `--new-button-label`
The button on the list that the user clicks onto to create a new record.
(Follows same rules described in the `--label` option but with the word "New" prepended.)

### `--new-form-heading`
The text at the top of the new form that appears when the new input entry is displayed.
(Follows same rules described in the `--label` option but with the word "New" prepended.)

### `--no-list-label`
Omits list LABEL itself above the list. (Do not confuse with the list heading which contains the field labels.)

Note that list labels may  be automatically omitted on downnested scaffolds.


## Field Labels

### `--form-labels-position` (default: `after`; options are **before**, **after**, and **omit**)
By default form labels appear after the form inputs. To make them appear before or omit them, use this flag.

See also `--form-placeholder-labels` to use placeolder labels.


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



`--code-before-create`
`--code-after-create`
`--code-before-update`
`--code-after-update`

Insert some code into the `create` action or `update` actions.
The **before code** is called _after authorization_ but _before saving_ (which creates the record, or fails validation).
The **after create** code is called after the record is saved (and thus has an id in the case of the create action).
Both should be wrapped in quotation marks when specified in the command line, and use semicolons to separate multiple lines of code.
(Notice the funky indentation of the lines in the generated code. Adjust you input to get the indentation correct.)


## Searching

### `--search` (options: simple, set, false predicate, default: false)


#### Set Search
If you specify `--search` to `set`, you will get a whole bar across the top of the list with search fields for each field.
Within the set, the search query is **_combinative_** ("and"), so records matching all criteria are shown as the **result set.**
For date pickers and time pickers, you need the additional Stimulus.
Install this with :

```
bin/rails generate hot_glue:set_search_interface_install
```

_Additional search option for Set Search_
##### `--search-fields=aaa,bbb,ccc,ddd,eee` 
to specify which fields you want to be searchable.


##### `--search-query-fields=aaa,ddd` 
to specify a list of strings only which will be taken out of the search set and presented in a singular query box (allowing search across multiple string fields)

##### `--search-position=vertical` 
to specify vertical or horizontal (default: horizontal)

##### `--search-clear-button` (no option) 
to specify whether to show a clear button to clear the whole search form at once (default: false)

##### `--search-autosearch` (no option) 
to specify whether to automatically search when the user exit or changes any field (default: false)

examples:
```
bin/rails generate Thing --include=name,description --search=set --search-fields=name,description
```

_Make a searchable table with two foreign keys (author_id and category_id) and a query field for title, including a clear button._
```
bin/rails generate Articles --inclue=title,author_id,category_id --search=set --search-fields=title,author_id,category_id --search-query-fields=title --search-clear-button
```

_Make a searchable table with vertical position and autosearch on._
```
bin/rails generate Inications --inclue=patient_id,drug_id,quantity --search=set --search-fields=patient_id,drug_id --search-position=vertical --search-autosearch
```


Here's how you would add a search interface to Example #1 in the [Hot Glue Tutorial](https://school.jfbcodes.com/8188)
```
bin/rails generate Book --include=name,author_id --search=set --search-fields=name,author_id
```





#### Predicate
NOT IMPLEMENTED YET
TODO: implement me








## Special Features

### `--attachments`

#### ActiveStorage Quick Setup
(For complete docs, refer to https://guides.rubyonrails.org/active_storage_overview.html)

`brew install vips`
(for videos `brew install ffmpeg`)

```
bundle add image_processing
./bin/rails active_storage:install
./bin/rails db:migrate
```

Generate an images model:

`./bin/rails generate model Images name:string`

add to `app/model/image.rb`, giving it a variant called thumb (Note: Hot Glue will fallback to using a variant called "thumb" if you use the shorthand syntax. If you use the long syntax, you can specify the variant to use for displaying the image)

```
has_one_attached :avatar do |attachable|
  attachable.variant :thumb, resize_to_limit: [100, 100]
end
```
Generate a Hot Glue scaffold with the attachment avatar appended to the field list (the shorthand syntax)

`./bin/rails generate hot_glue:scaffold Image --include='name:avatar' --gd --attachments='avatar'`

(Attachments behave like fields and follow the same layout rules used for fields, except that, unlike fields, when NOT using an --include list, they do not get automatically added. Thus, attachments are opt-in. You do not need to specify an attachment on the attachments list as ALSO being on the include list, but you can for the purpose of using the layout tricks discussed in Specified Grouping Mode to make the attachment appear on the layout where you want it to)

#### Caveats:
• If thumbnails aren't showing up, make sure you have

1) installed vips, and
2) used an image that supports ActiveStorage "variable" mechanism. The supported types are png, gif, jpg, pjpeg, tiff, bmp, vnd.adobe.photoshop, vnd.microsoft.icon, webp. see https://stackoverflow.com/a/61971660/3163663
To debug, make sure the object responds true to the variable? method.

If you use the shorthand syntax,  Hot Glue looks for a variant "thumb" (what you see in the example above). 

If it finds one, it will render thumbnails from the attachment variant `thumb`. To specify a variant name other than "thumb", use the first parameter below.

If using the shortform syntax and Hot Glue does **not find a variant** called `thumb` at the code generation time, it will build scaffolding without thumbnails.

#### `--attachments` Long form syntax with 1 parameter

**--attachments='_attachment name_{_variant name_}'** 

What if your variant is called something other than `thumb`

Use the long-form syntax specifying a variant name other than `thumb`. For example, `thumbnail`

`./bin/rails generate hot_glue:scaffold Image --include='name:avatar' --gd --attachments='avatar{thumbnail}'`

The model would look like this:
```
has_one_attached :avatar do |attachable|
  attachable.variant :thumbnail, resize_to_limit: [100, 100]
end
```

If using the long-form syntax with 1 parameter and Hot Glue does not find the specified variant declared in your attachment, it will stop and raise an error. 


#### `--attachments` Long form syntax with 1st and 2nd parameters

**--attachments='_attachment name_{_variant name_|_field for saving original filename_}'**

Grab the original file name of the uploaded file and stick it into a field called `name`

`./bin/rails generate hot_glue:scaffold Image --include='orig_filename:avatar' --gd --attachments='avatar{thumbnail|name} --show-only=name'`

Note: You must have a string field called `orig_filename`. It does not need to be visible, but if it is, it should be part of the `--show-only` list. (If it is not part of the show-only list, Hot Glue will overwrite it every time you upload a new file, making it so that any user's change might not stick.)

Note that the `orig_filename` is not part of the inputted parameters,  it simply gets appended to the model **bypassing the Rails strong parameters mechanism**, which is why it is irrelevant if it is included in the field list and recommended that if you do include it, you make it show-only so as not to allow your users to edit or modify it.

Note: The 1st and 2nd parameters may be left empty (use `||`) but the 3rd and 4th parameters must either be specified or the parameter must be left off. 

#### `--attachments` Long form syntax with 1st, 2nd, and 3rd parameters

An optional 3rd parameter to the long-form syntax allows you to specify direct upload using the word "direct", which will add direct_upload: true to your f.file_field tags.

Simply specify a 3rd parameter of `direct` to enable this attachment to use direct upload.

**--attachments='avatar{thumbnail|orig_filename|direct}'**

If you leave the 2nd parameter blank when using the 3rd parameter, it will default to NOT saving the original filename:

`--attachments='avatar{thumbnail||direct}'`


#### For S3 Setup


```
bundle add aws-sdk-s3
```


in `config/storage.yml`, enable this block and configure with the access key + secret associated with an AWS user that has permissions:

Also be sure to change `bucket`

```
# Use bin/rails credentials:edit to set the AWS secrets (as aws:access_key_id|secret_access_key)
amazon:
  service: S3
  access_key_id: <%= Rails.application.credentials.dig(:aws, :access_key_id) %>
  secret_access_key: <%= Rails.application.credentials.dig(:aws, :secret_access_key) %>
  region: us-east-1
  bucket: your_bucket-<%= Rails.env %> 

```


in development.rb or production.rb (or both), set
```
config.active_storage.service = :amazon
```


#### For Direct Upload Support
1. 
```
yarn add @rails/activestorage
```

2. You need a job runner like sidekiq or delayed_job. I recommend sidekiq. Make sure to have it 

- Start sidekiq with `bundle exec sidekiq` while you are testing

3. Install ActiveStorage JS using: 

`./bin/rails generate hot_glue:direct_upload_install`

AND be sure to use the 3rd parameter ('direct') when building a HG scaffold as explained above.


#### For Dropzone support
- Dropzone requires direct uploads, so you must have direct uploads enabled for the attachment you want to use dropzone with.


- Direct uploads requires that you have configured your external storage (S3, etc) correctly. See the ActiveStorage guide.

`yarn add dropzone`


(If you don't already have stimulus-rails, you will also need: `bundle add stimulus-rails` and `./bin/rails stimulus:install`)

Then run:
```
./bin/rails generate hot_glue:dropzone_install
```
This will 1) copy the dropzone_controller.js file into your app and 2) add the dropzone css into your app's application.css or application.bootstrap.css file.




### `--factory-creation={ ... }`

The code you specify inside of `{` and `}` will be used to generate a new object. The factory should instantiate with any arguments (I suggest Ruby keyword arguments) and must provide a method that is the name of the thing.

You may use semi-colons to separate multiple lines of code.

For example, a user Factory might be called like so:

`./bin/rails generate hot_glue:scaffold User --factory-creation={factory = UserFactory.new(params: user_params)} --gd`

(Note we are relying on the `user_params` method provided by the controller.)

You must do one of two things:

1) In the code you specify, set an instance variable `@user` to be the newly created thing. (Your code should contain something like `@thing = ` to trigger this option.)
2) Make a local variable called `factory` **and** have a method of the name of the object (`user`) on a local variable called `factory` that your code created

(The code example above is the option for #2 because it does not contain `@user =`)

If using number #2, Hot Glue will append this to the code specified:
```
@user = factory.user
```


Here's a sample UserFactory that will create a new user only if one with a matching email address doesn't exist. (Otherwise, it will update the existing record.)
Your initialize method can take any params you need it to, and using this pattern your business logic is applied consistently throughout your app. (You must, of course, use your Factory everywhere else in your app too.)

```
class UserFactory
    attr_reader :user
    attr_accessor :email

    def initialize(params: {})
        user = User.find_or_create_by(email: params[:email])
    
        user.update(params)
        if user.new_record?
            # do special new user logic here, like sending an email
        end
    end
end
```


be sure your factory code creates a local variable that follows this name

**<downcase association name>**_factory.<downcase association name>

Thus, your factory object must have a method of the same name as the factory being created which returns the thing that got created.
(It can do the creation either on instantiation or when calling that method)

For example, assuming the example from above, we are going to do the lookup ourselves inside of our own `AgentFactory` object.)

```
factory = AgentFactory.new(find_or_create_by_email: agent_company_params[:__lookup_email], 
                            params: modified_params)
```

Here the new AgentFactory will receive any variables by keyword argument, and since you're specifying the calling code here, Hot Glue does not dictate your factory's setup.
However, two special variables are in scope which you can use in your calling code.

`*_params` (where * is the name of the thing you are building)
`modified_params`

Either one must be received by your factory for your factory to create data based off the inputted data. 

Rememebr, `*_params` has the input params passed only the through the sanitizer, and modified_params has it passed through the timezone aware mechanism and other Hot Glue-specific defaults.

Always: 
• In your factory calling code, assign the variable `factory = ` (do not use a different variable name),
• Write a factory object with a `new` method that received the paramters you are specifying in your calling code,
• Be sure your factory has an _instance method_ a method with the **same name** of the built object, which hot glue will call next: 

`@agent = factory.agent`

Don't include this last line in your factory code. 

## Nav Templates
At the namespace level, you can have a file called `_nav.html.erb` to create tabbed bootstrap nav 

To create the file for the first time (at each namespace), start by running
```
bin/rails generate hot_glue:nav_template --namespace=xyz
```

This will append the file `_nav.html.erb` to the views folder at `views/xyz`. To begin, this file contains only the following:

```
<ul class='nav nav-tabs'>
</ul>
```

Once the file is present, any further builds in this namespace will:

1) Append to this `_nav.html.erb` file, adding a tab for the new built scaffold
2) On the list view of the scaffold being built, it will include a render to the _nav partial, passing the name of the currently-viewed thing as the local variable `nav` (this is how the nav template knows which tab to make active). 
```
<%= render partial: "owner/nav", locals: {nav: "things"} %>
```
(In this example `owner/` is the namespace and `things` is the name of the scaffold being built)

## Automatic Base Controller

Hot Glue will copy a file named `base_controller.rb` to the same folder where it tries to create any controller (so to the namespace), unless such a file exists there already.

The created controller will always have this base controller as its subclass. You are encouraged to implement functionality common to all the controllers in the *namespace* in the base class. For example, authorizing your user to access that part of the app. 

## Special Table Labels

If your object is very wordy (like MyGreatHook) and you want it to display in the UI as something shorter,
add `@@table_label_plural = "Hooks"` and `@@table_label_singular = "Hook"`. 

Hot Glue will use this as the **list heading** and **New record label**, respectively. This affects only the UI only.

You can also set these to `nil` to omit the labels completely. 

Child portals have the headings omitted automatically (there is a heading identifying them already on the parent view where they get included), or you can use the `--no-list-heading` on any specific build. 


## Field Types Supported

- Integers that don't end with `_id`: displayed as input fields with type="number"
- Foreign key integers: Integers that do end with `_id` will be treated automatically as associations. You should have a Rails association defined. (Hot Glue will warn you if it can't find one.)
  - Note:  if your foreign key has a nonusual class name, it should be using the `class_name:` in the model definition
- UUIDs (as primary key): Works seamlessly for the `id` field to make your primary key a UUID (Be sure to specify UUID in your model's migration). 
- UUIDs (as foreign key): All UUIDs that are not named `id` are assumed to be foreign keys and will be treated as associations.
- String: displayed as small input box 
- Text: displayed as large textarea
- Float: displayed as input box
- Datetime: displayed as HTML5 datetime picker
- Date: displayed as HTML5 date picker
- Time: displayed as HTML5 time picker
- Boolean: displayed radio buttons yes/ no
- Enum - displayed as a drop-down list (defined the enum values on your model). 
  - For Rails 6 see https://jasonfleetwoodboldt.com/courses/stepping-up-rails/enumerated-types-in-rails-and-postgres/
  - You must specify the enum definition both in your model and also in your database migration for both Rails 6 + Rails 7
  - You can modify an enum so that instead of a drop down list, it displays a partial view that you must build. See the [v0.5.23 Release notes](https://github.com/hot-glue-for-rails/hot-glue#2023-10-01---v0523) for details.




# Note about enums

The Rails 7 enum implementation for Postgres is very slick but has a counter-intuitive facet.

Define your Enums in Postgres as strings:
(database migration)
```
    create_enum :status, ["pending", "active", "archived"]

    create_table :users, force: true do |t|
      t.enum :status, enum_type: "status", default: "pending", null: false
      t.timestamps
    end
```

Then define your `enum` ActiveRecord declaration with duplicate keys & strings:
(model definition)
```
enum status: {
    pending: "pending",
    active: "active",
    archived: "archived",
    disabled: "disabled",
    waiting: "waiting"
  }
```

To set the labels, use a class-level method that is a hash of keys-to-labels using a method named the same name as the enum method but with `_labels`

If no `_labels` method exists, Hot Glue will fallback to using the Postgres-defined names.
```
def self.status_labels
    {
      pending: 'Is currently pending',
      active: 'Is really active',
      archived: 'Is done & archived',
      disabled: 'Is Disabled',
      waiting: 'Is Waiting'
    }
```

Now, your labels will show up on the front-end as defined in the `_labels` ("Is currently pending", etc) instead of the database-values.

You can modify an enum so that instead of a drop down list, it displays a partial view that you must build. See the [v0.5.23 Release notes](https://github.com/hot-glue-for-rails/hot-glue#2023-10-01---v0523) for details.

### Validation Magic

Use ActiveRecord validations or hooks to validate your data. Hot Glue will automatically display the errors in the UI.

TO prevent a record from being destroyed, use a syntax like this:

```
before_destroy :check_if_allowed_to_destroy

def check_if_allowed_to_destroy
  if (some_condition)
    self.errors.add(:base, "Cannot delete")
    raise ActiveRecord::RecordNotDestroyed("Cannot delete because of some condition")
  end
end

```

### Typeahead Foreign Keys

Let's go back to the first Books & Authors example.
assuming you have created
`bin/rails generate model Book title:string author_id:integer`
and
`bin/rails generate model Author name:string`
and also added `has_many :books` to Author and `belongs_to :author` to Book


You can now use a typeahead when editing the book. Instead of displaying the authors in a drop-down list, the authors will appear in a searchable typehead.

You will do these three things:

1. As a one-time setup step for your app, run
`bin/rails generate hot_glue:typeahead_install`
2. When generating a scaffold you want to make a typeahead association, use `--modify='parent_id{typeahead}'` where `parent_id` is the foreign key
`bin/rails generate hot_glue:scaffold Book --include=title,author_id --modify='author_id{typeahead}'`
3. Within each namespace, you will generate a special typeahead controller (it exists for the associated object to be searched on
`bin/rails generate hot_glue:typeahead Author`
This will create a controller for `AuthorsTypeaheadController` that will allow text search against any *string* field on the `Author` model.
This special generator takes flags `--namespace` as the normal generator and also `--search-by` to let you specify the list of fields you want to search by.

Your new and edit views that were built on books now give you a search box for the author spot. Notice that just making the selection
puts the value into the search box and the id into a hidden field.

You need to making a selection *and* click "Save" to update the record.

### TinyMCE
1. `bundle add tinymce-rails` to add it to your Gemfile

2. Add this inside of your `<head>` tag (at the bottom is fine)
```
    <%= tinymce_assets %>
```
3. Then, also inside of your `<head>` tag, add this:
```
<script>
      TinyMCERails.configuration.default = {
        selector: "textarea.tinymce",
        cache_suffix: "?v=6.7.0",
        menubar: "insert view format table tools",
        toolbar: ["bold italic | link | undo redo | forecolor backcolor | bullist numlist outdent indent | table | uploadimage | code"],
        plugins: "table,fullscreen,image,code,searchreplace,wordcount,visualblocks,visualchars,link,charmap,directionality,nonbreaking,media,advlist,autolink,lists",
        images_upload_url: "/uploader/image"
      };

    </script>
```

Then to `application.js` add

```
import "./tinymce_init"

```

create a file `tinymce_init.js` with this content

```
const reinitTiny = () => {
  tinymce.init({
    selector: 'textarea.tinymce', // Add the appropriate selector for your textareas
    // Other TinyMCE configuration options
  });
}

window.addEventListener('turbo:before-fetch-response', () => {
  tinymce.remove();
  tinymce.init({selector:'textarea.tinymce'});
})

window.addEventListener('turbo:frame-render', reinitTiny)
window.addEventListener('turbo:render', reinitTiny)
```

Once you have completed this setup, you can now use `--modify` with the modifier `tinymce`. 

For example, to display the field `my_story` on the object `Thing`, you'd generate with:

```
bin/rails generate Thing --include=my_story --modify='my_story{tinymce}'
```

### Pickup Partials

If you have a partial already in the view folder called `_edit_within_form.html.erb`, it with get included within the edit form.
If you have a partial already in the view folder called `_new_within_form.html.erb`, it with get included within the new form.
For these, you can use any of the objects by local variable name or the special `f` local variable to access the form itself.

These partials are good for including extra functionality in the form, like interactive widgets or hidden fields.
If you have a partial already in the view folder called `_edit_after_form.html.erb`, it with get included **_after_** the edit form.
If you have a partial already in the view folder called `_new_after_form.html.erb`, it with get included **_after_** the new form.
You can use any of the objects by local variable name (but you cannot use the form object `f` because it is not in scope.)
If you have  a partial already in your view folder called `_index_before_list`, it will be included above the list of records in the index view.

If you have a partial in your view folder called `_list_after_each_row`, it will be added after each row (be sure to include column divs)
If you have a partial in your view folder called `_list_after_each_row_heading`, it will be added after the heading row above the list_after_each_row content (be sure to include column divs)

The `within` partials should do operations within the form (like hidden fields), and the `after` partials should do entirely unrelated operations, like a different form entirely.

These automatic pickups for partials are detected at buildtime. This means that if you add these partials later, you must rebuild your scaffold.





# VERSION HISTORY


#### 2024-08-08 - v0.6.4 (renumbered v 6.0.3.3)

• Adds pickup partials for
`_index_before_list`
`_list_after_each_row`
`_list_after_each_row_heading`

Remember, to use pickup partials these partials must exist in the build folder at the time you are building scaffolding.

• Fixes issue with Rails 7.1 when using `--no-edit` or `--no-delete` flags
(Rails 7.1 enforces the presence of action names flagged with `only` on the before hook, which caused `The show action could not be found for the :load_charge callback...`)


#### 2024-07-29 - v0.6.3.3

• Adds pickup partials for
`_index_before_list`
`_list_after_each_row`
`_list_after_each_row_heading`

Remember, to use pickup partials these partials must exist in the build folder at the time you are building scaffolding.

• Fixes issue with Rails 7.1 when using `--no-edit` or `--no-delete` flags
(Rails 7.1 enforces the presence of action names flagged with `only` on the before hook, which caused `The show action could not be found for the :load_charge callback...`)



#### 2024-01-28 - v0.6.3.2
- corrects variables to be top-level in for nested merge in edit.erb; also adds new flag --display-edit-after-create used to direct to the edit page after the create action (#157)
- code spacing tweeks
- picks up all columns if no search fields specified
- fixes top_level setting on edit.erb


#### 2024-01-16 - v0.6.3.1
Adds support for boolean modified datetime search; now, when using a modify= to turn a datetime into a boolean, the search box behaves appropriately and shows a 3-way radio picker: all, falsy, truthy.
(Only implemented for datetime)

#### 2024-01-15 - v0.6.3

## Set Searching

### `--search` (options: set, false default: false)

(Future options include simple, predicate)

A set search is a search form that allows you to search across multiple fields at once. It is a set of search fields, each of which is a search field for a single field.


#### Set Search
If you specify `--search` to `set`, you will get a whole bar across the top of the list with search fields for each field.
Within the set, the search query is **_combinative_** ("and"), so records matching all criteria are shown as the **result set.**
For date pickers, time pickers, and the clear form interaction, you need the additional Stimulus JS. 
Install this with :

```
bin/rails generate hot_glue:set_search_interface_install
```

_Additional search option for Set Search_
##### `--search-fields=aaa,bbb,ccc,ddd,eee`
to specify which fields you want to be searchable.

##### `--search-query-fields=aaa,ddd`
to specify a list of strings only which will be taken out of the search set and presented in a singular query box (allowing search across multiple string fields)

##### `--search-position=vertical`
to specify vertical or horizontal (default: horizontal)

##### `--search-clear-button` (no option)
to specify whether to show a clear button to clear the whole search form at once (default: false)






#### 2023-12-02 - v0.6.2

• Fixes to typeahead when using Pundit.

• New Code Hooks: Add Custom Code Before/After the Update or Create Actions

`--code-before-create`
`--code-after-create`
`--code-before-update`
`--code-after-update`


Insert some code into the `create` action or `update` actions.

The **before code** is called _after authorization_ but _before saving_ (which creates the record, or fails validation). 

The **after create** code is called after the record is saved (and thus has an id in the case of the create action). 

Both should be wrapped in quotation marks when specified in the command line, and use semicolons to separate multiple lines of code.
(Notice the funky indentation of the lines in the generated code. Adjust you input to get the indentation correct.)

• New Automatic Pickup Partial Includes for `_edit` and `_new` Screens

See "Pickup Partial Includes for `_edit` and `_new` Screens" above



#### 2023-11-21 - v0.6.1 - `--related-sets`

Used to show a checkbox set of related records. The relationship should be a `has_and_belongs_to_many` or a `has_many through:` from the object being built.

Consider the classic example of three tables: users, user_roles, and roles

User `has_many :user_roles`; UserRole `belongs_to :user` and `belongs_to :role`; and Role `has_many :user_roles` and `has_many :user, through: :user_roles`

We'll generate a scaffold to edit the users table. A checkbox set of related roles will also appear to allow editing of roles. (In this example, the only field to be edited is the email field.)

```
rails generate hot_glue:scaffold User --related-sets=roles --include=email,roles --gd
```

Note that when making a scaffold like this, you may leave open a privileged escalation attack (a security vulnerability).

To fix this, you'll need to use Pundit with special syntax designed for this purpose. 

For a complete solution, please see Example 17 in the [Hot Glue Tutorial](https://school.jfbcodes.com/8188).

Without Pundit, due to a quirk in how this code works with ActiveRecord, all update operates to the related sets table are permitted (and go through), even if the update operation otherwise fails validation for the fields on the object. (ActiveRecord doesn't seem to have a way to validate the related sets directly.)

In this case, your update actions may update the relate sets table but fail to update the current object.

Using this feature with Pundit will fix this problem, and it is achieved with a (hacky) implementation that performs a pre-check for each related set against the Pundit policy. 

#### v0.6.0.1 - small tweaks to typeahead

#### 2023-11-03 - v0.6.0

Typeahead Associations

You can now use a typeahead when editing any foreign key.

Instead of displaying the foreign key in a drop-down list, the associated record is now selectable 
from a searchable typehead input. 

The typeahead is implemented with a native Stimulus JS pair of controllers and is a modern & clean replacement to the old typeahead options.

1. As a one-time setup step for your app, run
   `bin/rails generate hot_glue:typeahead_install`
2. When generating a scaffold you want to make a typeahead association, use `--modify='parent_id{typeahead}'` where `parent_id` is the foreign key
   `bin/rails generate hot_glue:scaffold Book --include=title,author_id --modify='author_id{typeahead}'`
3. Within each namespace, you will generate a special typeahead controller (it exists for the associated object to be searched on
   `bin/rails generate hot_glue:typehead Author`
   This will create a controller for `AuthorsTypeaheadController` that will allow text search against any *string* field on the `Author` model.
   This special generator takes flags `--namespace` like the normal generator and also `--search-by` to let you specify the list of fields you want to search by.

The example Books & Authors app with typeahead is here:

https://github.com/hot-glue-for-rails/BooksAndAuthorsWithTypeahead2


#### 2023-10-23 - v0.5.26

Various fixes:
- fixed alert (danger) classes for bootstrap 5 ('alert alert-danger' was just 'alert-danger')
- switches to use a self-defined instance var @action instead of action_name; this is so I can 
  switch it back to 'new' or 'edit' upon a failure re-display to have the view behave the expected way
- fix in create.turbo_stream.erb for failure redisplay (was not working)
- fixes syntax error (in generated code) in edit.erb when there was a nested set


#### 2023-10-16 - v0.5.25

- Fixes scoping on Pundit-built controllers; even when using pundit we should still wrap to the current build's own ownership scope (#132
- don't write to the nav file if we're building a nested controller (#134)
- adds system specs for self-auth feature
- Pagination Fixes:

A new flag `--paginate-per-page-selector` (default false) will allow you to show a small drop-down to let the user choose 10, 25, or 100 results per page.

To get pagination to work, choose either #1 OR #2 below. #1 will replace the templates in app/views/kaminari so don't do that if you have modified them since first generating them out of Kaminari.

1. Replace the kaminari gem with my fork and regenerate your templates
bundle remove kaminari
bundle add kaminari --git="https://github.com/jasonfb/kaminari.git" --branch="master"
bundle install
rm -rf app/views/kaminari
rails g kaminari:config


2. Go into app/views/kaminari/ and modify each template in this folder by adding ` 'data-turbo-action': 'advance'` to all of the links (which mostly appear in this code as the `link_to_unless` helper-- add the parameter onto the end of the calls to those helpers.) 



#### 2023-10-07 - v0.5.24

- TinyMCE implementation. See 'TinyMCE' above.
Note: I also plan to implement ActionText as an alternative.  However, because TinyMCE is implemented with a `text` field type an ActionText is implemented with a Rails-specific `rich_text` field type, the two mechanisms will be incompatible with one another. TinyMCE has an annoying drawback in how it works with Turbo refreshes (not very consistently), and style of loading Javascript is discordant with Rails moving forward. So I am leaving this implementation as experimental.
- Spec Savestart code: In the behavior specs, there is a code marker (start & end) where you can insert custom code that gets saved between 
build. The start code maker has changed from `#HOTGLUE-SAVESTART` to `# HOTGLUE-SAVESTART`
and the end code marker has changed from `#HOTGLUE-END` to `# HOTGLUE-END`. This now conforms to Rubocop. 
Be sure to do find & replace in your existing projects to keep your custom code.
- Fix for specs for attachment fields. If you have attachments fields, you must have a sample file at `spec/fixtures/glass_button.png`
- Pundit now correctly protects the `index` action (authorize was missing before)

#### 2023-10-01 - v0.5.23

- You can now use the modify flag on enum type fields to display a partial with the same name of that enum type.

`--modify=status{partials}`

Here, `status` is an enum field on your table; you must use the exact string `partials` when using this feature.

You're telling Hot Glue to build scaffold that will display the `status` enum field as a partial. 

It will look for a partial in the same build directory, whose name matches to the value of the enum. You will need to create a partial _for each enum option_ that you have defined.

Remember when defining enums Rails will patch methods on your objects with the name of the enum types, so you must avoid namespace collisions with existing Ruby or Rails methods that are common to all objects -- like, for example, `new`.

- Before this feature, enums always rendered like this on the show page:
`<%= domain.status %>`
(or, if you use custom labels:)
`<%= Domain.status_labels(domain.status)`

- After, you if you use the `--modify` flag and modify the enum to 'partials', your show output will render:
```
<%= render partial: thing.status, locals: {thing: thing} %>
```
(In this example `Thing` is the name of the model being built.)

Your form will also render the partial, but after the collection_select used to create the drop-down.
(This implementation has the draw-back that there is no immediate switch between the partials when changing the drop-down)

Assuming your Thing enum is defined like so:
```
enum :status {abc: 'abc', dfg: 'dfg', hgk: 'hgk'}
```

You then would create three partials in the `things` directory. Make sure to create a partial for each defined enum, or else your app will crash when it tries to render a record with that enum.
```
_abc.html.erb
_dfg.html.erb
_hgk.html.erb
```

If your enum is on the show-only list, then the drop-down does not appear (but the partial is rendered).

Proof-of-concept can be found here:
https://github.com/hot-glue-for-rails/HGEnumWithPartials1

Remember to see the section marked 'A Note About Enums' for more about working with Rails 7 enums.


#### 2023-09-20- v0.5.22
- adds back magic button tap-away params in the controller
- changes creation of flash[:notice] in update method
- adds pundit authorization for edit action in the edit method itself
- adds a crude show method that redirects to the edit (Hot Glue takes the opinionated stance that show routes should not really exist. This addition makes it so that when the user is on the show route and re-loads the browse window, they don't see a route error)
- adds RuboCop detection; omits the regen code at the top of the controller from line length cop 
- fixes for specs

#### 2023-09-18 - v0.5.21
- Removes `@` symbols using instance variables in `_edit` partials and in the enum syntax
- fixes in system_spec.rb.erb
- Adds flags --no-controller --no-list
- adds regen code to a file in the views folder REGENERATE.md if you have set --no-controller


#### 2023-09-08 - v0.5.20
`--pundit` authorization
• Will look for a `XyzPolicy` class and method on your class named `*_able?` matching the fields on your object. See Pundit section for details.
• Field-level access control (can determine which fields are editble or viewable based on the record or current user or combination factors)
• The field-level access control doesn't show the fields as editable to the user if they can't be edited by the user (it shows them as view-only). 

#### 2023-09-02 - v0.5.19

Given a table generated with this schema:
```
rails generate model Thing abc:boolean dfg:boolean hij:boolean klm_at:datetime
```

• You can now use new flag `--display-as` to determine how the booleans will be displayed: checkbox, radio, or switch

rails generate hot_glue:scaffold Thing --include=abc,dfg,hij,klm_at --god --modify='klm_at{yes|no}' --display-as='abc{checkbox},dfg{radio},hij{switch}'

You may specify a default `default_boolean_display` in `config/hot_glue.yml`, like so:
:default_boolean_display: 'radio'

(The options are checkbox, radio, or switch.)
If none is given and no default is specified, legacy display behavior will be used (radio buttons)

![Screenshot 2023-08-22 at 7 40 44 PM](https://github.com/hot-glue-for-rails/hot-glue/assets/59002/ba076cb0-fa40-4b68-a1a0-cab496670e00)

You still use the `--modify` flag to determine the truthy and falsy labels, which are also used as the truth and false when a boolean is displays as radio button, as shown in the `klm_at` field above. (switches and checkboxes simply display with the field label and do not use the truthy and falsy labels)



#### 2023-09-01 - v0.5.18
- there three ways Hot Glue deals with Datetime fields:
- 
- (1) with current users who have `timezone` method (field or method)
- (2) without current user timezone and no global timezone set for your app
- (3) without current user timezone and global timezone set for your app

- For #1, previously this method returned a time zone offset (integer). After v0.5.18, the preferred return value is a Timezone string, but legacy implementation returning offset values will continue to work. 
  Your user objects should have a field called `timezone` which should be a string.
- Note that daylight savings time is accounted for in this implementation. 

- For #2 (your user does not have a timezone field and you _have not_ set the timezone globally), all datetimes will display in UTC timezone. 

- For #3  (your user does not have a timezone field but you _have_ set the timezone globally), your datetimes will display in the Rails-specified timezone.

- be sure to configure in `config/application.rb` this: 
```
config.time_zone = 'Eastern Time (US & Canada)'
```
This should be your business's default timezone.


(#93)
fixes variables be more clear if they are TimeZone objects (https://api.rubyonrails.org/classes/ActiveSupport/TimeZone.html) or are UTC offset (integers -/+ from UTC)
- fixes spec assertions for DateTime and Time fields
- removes randomness causing race conditions in the datetime object specs
**- fixes issue where setting bootstrap-column-width was not preferred if… (#88)**
- fixes flash notice output


#### 2023-08-18 - v0.5.17

• Nav templates (`_nav.html.erb`) are now automatically appended to if they exist. Remember nav template live in the views folder at the root of the *namespace*, which is one folder up from whatever folder is being built.
If a file exists `_nav.html.erb`, it will get appnded to with content like this:

```
<li class="nav-item">
    <%= link_to "Domains", domains_path, class: "nav-link #{'active' if nav == 'domains'}" %>
  </li>
```

This append to the `_nav.html.erb` template happens in addition to the partial itself being included from the layout.
(Also only if it exists, so be sure create it before running the scaffold generators for the namespace. Of course, you only need to create it once for each namespace)

• To create a new `_nav.html.erb` template use

```
bin/rails generate hot_glue:nav_template --namespace=xyz
```

Here, you give only the namespace. It will create an empty nav template:
```
<ul class='nav nav-tabs'>
</ul>
```

• Fixes to specs for datetimes

• Fixes way the flash notices where created that violated frozen string literal


#### 2023-08-17 - v0.5.16

- Adds `--modidy` flag to turn numbers into currency and apply binary labels (see docs for `--modify` flag)

#### 2023-08-11 - v0.5.15

- When using big edit, updating a child will now re-render the parent EDIT record automatically.

For example
`rails generate hot_glue:scafold Invoice --big-edit`
`rails generate hot_glue:scafold LineItem --nested=invioce`

Whenever the line item is created, updated, or destroyed, the parent invoice record gets (edit action) re-rendered automatically. This happens for the big edit screen of the invoice.

- Refactors fields into polymoric objects

- Adds test coverage for Postgres Enums


#### 2023-05-14 - v0.5.14 Delete message flash notice and new flash notice partial

- This changes to how flash_notices work.
- After you upgrade to 0.5.14 from a prior version, please re-install the global flash notice
- template with:

`rails generate hot_glue:flash_notices_install` 

The newer template will work with old Hot Glue scaffold (generated prior to 0.5.14) and new scaffold moving forward.

If you miss this step, your old Hot Glue flash notices template will not show the model error messages (but will continue to show the global alert & notice messages)

- The destroy action on controllers now produces an "alert" message for successful deletion.

#### 2023-04-24 - v0.5.12
- adds new option for `bootstrap_column_width` (default is 2) to specify the number of bootstrap columns a visual column should take up
- You can specify this as a builder option (`--bootstrap-column-width`)
or in your `config/hot_glue.yml` file. Passing option will override config setting
- Adds new option for `button_icons` (default to "font-awesome"); use `none` to have no button icons
- When using big edit with downnested portals, the downnested portals now display on the edit page instead of the list page.

#### 2023-04-19 - renamed previous version to v0.5.11

#### 2023-04-08 - v0.5.9.2
• This begins a refactor of the field knowledge into properly abstracted Field objects
• No functional changes, except that the specs now contain an `attach_file` for attachments.

#### - v0.5.9.1
• Fixed issue with ownership fields coming through as associations.

#### 2023-03-17 - v0.5.9
- Attachments! You can use Hot Glue to seamlessly create an image, file, or video attachment. Please see the docs in new flag `--atachments` under the "Special Features" section

- Watch the demo on attachments here on YouTube: https://youtu.be/yJbjwReCr18

- Fixes to downnesting

- `--stacked-downnesting` flag — The Layout Builder now can stack downnesting portals instead of putting them side-by-side. When stacked, there is no limit to how many you can have and the entire stack takes up 4-bootstrap columns. 

- Hot Glue has been moved on Github from my personal organization to a new organization named `hot-glue-for-rails`. The new Github url is: `https://github.com/hot-glue-for-rails/hot-glue`


#### 2023-03-01 - v0.5.8 

• Fixes spec assertions for enums to work with the enum `_label` field (when provided).

• Fixes `--form-label-position` (before/after) so that a carriage return is placed between the label & field correctly for either choice

• All spec files are now created in `spec/features/` folder (previously was `spec/system/` with `type: :feature`; they no longer have `type: :feature` as this is not necessary when they are in the `spec/features` folder)

• Corrects the hawk scope to only add the plural related entity when NOT using the shorthand `{ ... }`

• BEM (block element modifier)-style has been added list headings, show cells, edit cells. These class names will get added to the `<div>` tags for both the heading and cells. 

The format is as follows:

For headings
    `heading--{singular}--{field name}-{field name}-{field name}`

For cells:
    `cell--{singular}--{field name}-{field name}-{field name}`
   use this to globally style different fields by object & field name

Note that if you have multiple fields inside one cell (for example, with specified grouping or smart layout), your fields names get concatenated using single-hyphens:
For example, consider a customer scaffold with a first name & last name appearing in one cell. The cell itself will have a class of:
`cell--customer--first_name-last_name`

If your cell contains only one field, for example, a phone number, it would look like this:
`cell--customer--phone_number`

Tip: Use the _ends with_ and _starts with_ selectors, which can be used like this:.

```
div[class$="--phone_number"] {
    text-decoration: underline; 
}
```


```

```


#### 2023-02-13 - v0.5.7 - factory-creation, alt lookups, update show only, fixes to Enums, support for Ruby 3.2
• See `--factory-creation` section.

• `--alt-lookup-foreign-keys`
Allows you to specify that a foreign key should act as a search field, allowing the user to input a unique value (like an email) to search for a related record.

• `--update-show-only`
Allows you to specify a list fields that should be show-only (non-editable) on the **edit** page but remain inputable on the **create** page. 
Note that a singular partial `_form` is still used for new & edit, but now contains `if` statements that check the action and display the show-only version only on the edit action. 

• Syntax fix to support Ruby 3.2.0 (the installer was broken if you used Ruby 3.2)

• Tweaks to how Enums are display (see "Note about Enums")


#### 2023-01-02 - v0.5.6
- Changes the long-form of the hawk specifier to require you to use the has_many of the relationship you are hawking (previously, it was assumed). See Hawk for details
- Adds "Regenerate me" comment to top of all generated controllers
- Change behavior of pluralization. Now, you can use an `inflections.rb` file and non-standard pluralization will be respected.


#### 2022-12-27 - v0.5.5 

- Experimental support for Tailwind. Note I was not able to get Tailwind actually working in my app, and I'm not sure about how to think about the many flavors of Tailwind (all of which seem to be paid?). If anyone can lend a hand, the objects are now cleanly refactored so that the CSS logic is separated.

- Support for UUIDs. Database UUIDs are treated as foreign keys and behave like integers ending with _id (they are treated as foreign keys whether or not they end with _id where as integers are treated as foreign keys only if they end with _id)

- At the namespace level, you can now have a file called `_nav.html.erb` like this example for a two-tab bootstrap nav (you'll need to create this file manually). 
- Here, our two tabs are called "Domains" and "Widgets"

```
<ul class="nav nav-tabs">
  <li class="nav-item">
    <%= link_to "Domains", domains_path, class: "nav-link #{'active' if nav == 'domains'}" %>
  </li>
  <li class="nav-item">
  	<%= link_to "Widgets", widgets_path, class: "nav-link #{'active' if nav == 'widget'}" %>	
  </li>
</ul>
```

If the file is present, Hot Glue will automatically add this to the top of, for example, the "domains" index page:

```
<%= render partial: "owner/nav", locals: {nav: "domains"} %>
```
Use this to build a Bootstrap nav that correctly turns each tab active when navigated to.

#### 2022-11-27 - v0.5.4 - new flag --with-turbo-streams will append callbacks after_update_commit and after_destroy_commit to the MODEL you are building with to use turbo to target the scaffolding being built and programmatically update it

Adds `--with-turbo-streams`. Use `--with-turbo-streams` to create hot (live reload) interfaces. See docs above.


#### 2022-11-24 - v0.5.3 - New testing paradigm & removes license requirements

New testing paradigm
Code cleanup
Testing on CircleCI
License check has been removed (Hot Glue is now free to use for hobbyists and individuals. Business licenses are still available at https://heliosdev.shop/hot-glue-license)


#### 2022-03-23 - v0.5.2 - Hawked Foreign Keys

 - You can now protect your foreign keys from malicious input and also restrict the scope of drop downs to show only records with the specified access control restriction.
 - [Example #3](https://school.jfbcodes.com/8188) in the Hot Glue Tutorial shows you how to use the hawk to limit the scope to the logged in user.
 - [Example #4](https://school.jfbcodes.com/8188) in the Hot Glue Tutorial shows how to hawk to a non-usual scope, the inverse of the current user's belongs_to (that is, hawk the scope to X where current_user `belongs_to :x`)
 

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

`rspec spec`

Internal Test coverage as of 2023-10-15 (v0.5.24)
All Files ( 86.29% covered at 75.64 hits/line )


### Reference

https://stackoverflow.com/questions/78313570/unable-to-bundle-install-nio4r-on-a-new-mac-m3

