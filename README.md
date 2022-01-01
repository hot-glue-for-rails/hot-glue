
[![Build Status](https://app.travis-ci.com/jasonfb/hot-glue.svg?branch=main)](https://travis-ci.com/jasonfb/hot-glue)


Hot Glue is a Rails scaffold builder for the Turbo era. It is an evolution of the admin-interface style scaffolding systems of the 2010s ([activeadmin](https://github.com/activeadmin/activeadmin), [rails_admin](https://github.com/sferik/rails_admin), and [active_scaffold](https://github.com/activescaffold/active_scaffold)).


Using Turbo-Rails and Hotwire (default in Rails 7) you get a lightning-fast out-of-the-box CRUD building experience.

Every page displays only a list view: new and edit operations happen as 'edit-in-place', so the user never leaves the page.

Because all page navigation is Turbo's responsibilty, everything plugs & plays nicely into a Turbo-backed Rails app.

Alternatively, you can use this tool to create a Turbo-backed *section* of your Rails app-- like an admin interface -- while still treating the rest of the Rails app as an API or building out other features by hand.

It will read your relationships and field types to generate your code for you, leaving you with a 'sourdough starter' to work from. If you modify the generated code, you're on your own if you want to preserve your changes and also re-generate scaffold after adding fields.

By default, it generates code that gives users full control over objects they 'own' and by default it spits out functionality giving access to all fields.

Hot Glue generates functionality that's quick and dirty. It lets you be crafty. As with a real hot glue gun, use with caution.

* Build plug-and-play scaffolding mixing generated ERB or HAML with the power of Hotwire and Turbo-Rails
* Everything edits-in-place (unless you use --big-edit, then it won't)
* Automatically Reads Your Models (make them before building your scaffolding!)
* Excellent for CREATE-READ-UPDATE-DELETE (CRUD), lists with pagination (coming soon: searching & sorting)
* Great for prototyping, but you should learn Rails fundamentals first.
* 'Packaged' with Devise, Kaminari, Rspec, FontAwesome
* Create system specs  automatically along with the generated code.
* Nest your routes model-by-model for built-in poor man's authentication.
* Throw the scaffolding away when your app is ready to graduate to its next phase.

# Hot Glue Tutorial 
## [GET THE COURSE TODAY (includes Hot Glue License)](https://jfb.teachable.com/courses/hot-glue-in-depth-tutorial/) **only $60 USD!**

| ------------- | ------------- |
| ![Teachable-225x225](https://user-images.githubusercontent.com/59002/147857335-a919e095-e6de-4718-8513-736d1f283a0b.png)  | Now avaiale on [Teachable](https://jfb.teachable.com/courses/hot-glue-in-depth-tutorial/)  |







## HOW EASY?

```
rails generate hot_glue:scaffold Thing 
```

Generate a quick scaffold to manage a table called `pronouns`
![hot-glue-3](https://user-images.githubusercontent.com/59002/116405509-bdee2f00-a7fd-11eb-9723-4c6e22f81bd3.gif)

Instantly get a simple CRUD interface

![hot-glue-4](https://user-images.githubusercontent.com/59002/116405517-c2b2e300-a7fd-11eb-8423-d43e3afc9fa6.gif)

# Getting Started

_If you are on Rails 6, skip to section Rails 6 Setup and complete those steps FIRST._


## 1. ADD RSPEC, FACTORY-BOT, AND FFAKER

add these 3 gems to your gemfile **inside a group for both :development and :test*. Do not add these gems to only the :test group or else your will have problems with the generators.
```
gem 'rspec-rails'
gem 'factory_bot_rails'
gem 'ffaker'
```

- run `rails generate rspec:install`

- replace `application.css` with a new file (delete old contents) `application.scss`

THIS FILE CAN BE EMPTY, BUT WILL BE USED BY THEME INSTALLER

## 2. ADD BOOTSTRAP (OPTIONAL)

_BOOTSTRAP IS NO LONGER NEEDED_, but I recommend it.

IF you are using `--layout=bootstrap` (step 3), you must install Bootstrap here.

Bootstrap with Webpacker is no longer in Rails 7 by default. (For that see ________TBD________)

For Bootstrap with Sprockets (recommended by Rails team), see https://github.com/twbs/bootstrap-rubygem

If going the the Bootstrap with Sprockets route, note the gem is
```
gem 'bootstrap', '~> 5.1.3'
```

Then, all you need to do is add to `app/assets/stylesheets/application.scss`

```
@import "bootstrap";
```

## 3. HOTGLUE INSTALLER
Add `gem 'hot-glue'` to your Gemfile & `bundle install`

Purchase a license at https://heliosdev.shop/hot-glue-license

During in installation, you MUST supply a `--layout` flag.

### `--layout` flag
Here you will set up and install Hot Glue for the first time. It will install a config file that will save two preferences: layout (hotglue or bootstrap) and markup (erb or haml or slim).

Once you run the installer, the installer will save what you set it to in `config/hot_glue.yml`. Newly generated scaffolds will use these two settings, but you can modify them just by modifying the config file (you don't need to re-run the installer)

If you do NOT specify `--layout=bootstrap`, then `hotglue` will be assumed. When constructing scaffold with bootstrap layout (at this time Hot Glue peeks into config/hot_glue.yml to see what you've set there), your views come out with divs that have classes like .container-fluid, .row, and .col. You'll need to install Bootstrap separately, any way you like, but jQuery is not required as Hot Glue does not rely on jQuery-dependant Bootstrap features.


If instead you install Hot Glue (or switch the setting) using the default layout mode (`--layout=hotglue`),
your scaffolding will be built using no-Bootstrap syntax: It has its own syntax with classes like
`.scaffold-container`,
`.scaffold-list`,
`.scaffold-row`, and
`.scaffold-cell`

During the installation, if your `--layout` flag is left unspecified or set to `hotglue` you must also pass `--theme` flag.

the themes are:
• like_mountain_view (Google)
• like_los_gatos (Netflix)
• like_bootstrap (bootstrap 4 copy)
• dark_knight (_The Dark Night_ (2008) inspired)
• like_cupertino (modern Apple-UX inspired)
• gradeschool (spiral bound/lined notebook inspired)

Please note that the scaffold is ** built with different market up for boostrap**, so you cannot switch between the Bootstrap and Hotglue layouts without rebuilding the scaffold.

(On the other hand, if you build within the Hotglue layout, all of the Hotglue theme files CAN be swapped out without rebuilding the scaffold.)

The themes are just SCSS files installed into app/assets/stylesheets. You can tweak or modify or remove them after they get installed.


### `--markup` flag

default is `erb`


## 3. RUN HOT-GLUE INSTALL:
### example installing ERB using Bootstrap layout:
`rails generate hot_glue:install --markup=erb --layout=bootstrap`

### Example installing HAML using Hot Glue layout and the 'like_mountain_view' (Gmail-inspired) theme:
`rails generate hot_glue:install --markup=erb --layout=hotglue --theme=like_mountain_view`


##  3(B). Modify `application.html.erb`
(THIS WAS AUTOMATICALLY DONE BY THE HOT GLUE INSTALLATION -- CONFIRM CHANGES ONLY)
Note: if you have some kind of non-standard application layout, like one at a different file
or if you have modified your opening <body> tag, this may not have been automatically applied by the installer.

- This was added to your `application.html.erb`
```
  <%= render partial: 'layouts/flash_notices' %>
```

## 3(C). Modify `rails_helper.rb`
(THIS WAS AUTOMATICALLY DONE BY THE HOT GLUE INSTALLATION)
Note: if you have some kind of non-standard rails_helper.rb, like one that does not use the standard ` do |config|` syntax after your `RSpec.configure`
this may not have been automatically applied by the installer.

- configure Rspec to work with Factory Bot inside of `rails_helper.rb`
  ```
  RSpec.configure do |config|
      // ... more rspec configuration (not shown)
      config.include FactoryBot::Syntax::Methods
  end
  ```  


## 3(D) CAPYBARA: SWITCH FROM RACK-TEST TO HEADLESS CHROME
(THIS WAS AUTOMATICALLY DONE BY THE HOT GLUE INSTALLATION)

- By default Capybara is installed with :rack_test as its driver.
- This does not support Javascript, and the code from Hot Glue IS NOT fallback compatible-- it will not work on non-Javascript browsers.
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

Alternatively, can define your own driver like so:

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


(THIS WAS ALSO AUTOMATICALLY DONE BY THE HOT GLUE INSTALLATION)

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


## 4. install font-awesome (optional)

I recommend
https://github.com/tomkra/font_awesome5_rails
or
https://github.com/FortAwesome/font-awesome-sass


## 5. Devise

(or only use --gd mode, see below)

Add to your Gemfile

As of 2021-12-28 Devise for Rails 7 is still not released so you must use main branch, like so:
`gem 'devise', branch: 'main', git: 'https://github.com/heartcombo/devise.git'`

If on Rails 6 **or** Rails 7, you must do the steps in **Legacy Step #5** (below).

(If you are on Rails 6, you must do ALL of the steps in the Legacy Setup steps.)

To be clear: You CAN use Devise with Rails 7, but you must still do the Legacy Step #5 described below for your login to work.

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


As described in Legacy Step #5, **you cannot** skip Devise installer Step 4, even though the installer tells you it is optional:
``` 
  4. You can copy Devise views (for customization) to your app by running:

       rails g devise:views
       
```
Once you copy the files, you must modify the Devise views to disable Turbo as described in Legacy Step #5.


## LEGACY SETUP FOR RAILS 6

(Note Legacy Step #5 is necessary for BOTH Rails 6 and Rails 7.)


## Legacy Step #1. ADD HOTWIRE
(RAILS 6 ONLY— SKIP THIS STEP FOR RAILS 7)
```
yarn add @hotwired/turbo-rails
```
or `npm install @hotwired/turbo-rails`


## Legacy Step #2. SWITCH FROM TurblLinks to Turbo-Rails
(RAILS 6 ONLY — SKIP FOR RAILS 7)
(THIS WAS AUTOMATICALLY DONE BY THE HOT GLUE INSTALLATION -- CONFIRM CHANGES ONLY)
- Add `gem 'turbo-rails'` to your Gemfile & `bundle install`
- Then install it with `rails turbo:install`
- The Turbo install has switched your action cable settings from 'async' to Redis, so be sure to start a redis server
- in `app/javascript/packs/application.js` remove this line
```
import Turbolinks from "turbolinks"
```
and replace it with
```
import { Turbo } from "@hotwired/turbo-rails"
```


Also replace
``` 
Turbolinks.start()
```
with:
```
Turbo.start()
```


## Legacy Step #3. INSTALL WEBPACKER
(_SKIP FOR RAILS 7_ unless you want to use Webpacker with Rails 7)

** For webpacker, you must be using Node version ^12.13.0 || ^14.15.0 || >=16 **

I recommend Node Version Manager (NVM) to switch between nodes. You will not be able to get through the following command with a Node version that does not match above.

Check your node version with `node -v`

```
`yarn add @rails/webpacker`
```


rails webpacker:install

## Legacy Step #4: ENUM Support
For Enum support, I recommend activerecord-pg_enum
Instructions for Rails 6 are here:
https://jasonfleetwoodboldt.com/courses/stepping-up-rails/enumerated-types-in-rails-and-postgres/

_This functionality is now built-in to Rails 7._


## Legacy Step #5-- Fix Devise if adding Turbo To Your Project
## IMPORTANT: Devise currently has serious compatibility issues with Turbo Rails. In particular, your log-in screens do not work out of the box. Follow the next step to fix them.

Manually port the Devise views into your app with

`rails generate devise:views`

Edit `devise/registrations/new`, `devise/sessions/new`, `devise/passwords/new` and `devise/confirmations/new` modifying all four templates like so:

form_for(resource, as: resource_name, url: session_path(resource_name) ) do |f|



add the data-turbo false option in the html key:


form_for(resource, as: resource_name, **html: {'data-turbo' => "false"},** url: session_path(resource_name) ) do |f|



This tells Devise to fall back to non-Turbo interaction for the log-in and registration. For the rest of the app, we will use Turbo Rails interactions.


---
---


# HOT GLUE DOCS


## First Argument
(no double slash)

TitleCase class name of the thing you want to build a scaffoling for.


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


### `--nest=`

pass `--nest=` to denote a nested resources


`rails generate hot_glue:scaffold Line --nest=invoice`

In this example, it is presumed that the current user has_many :invoices, and that invoices have many :lines


For multi-level nesting use slashes to separate your levels of nesting. Remember, you should match what you have in your routes.rb file.

```
resources :invoices do
    resources :lines do
        resources :charge
    end    
end

```
In this example, it is presumed that the current user has_many :invoices, and that invoices have many :lines, and that lines have many :charges


To generate scaffold:
`rails generate hot_glue:scaffold Charge --nest=invoice/line`

The order of the nest should match the nested resources you have in your own app.  In particular, you auth root will be used as the starting point when loading the objects from the URL:

In the example above, @invoice will be loaded from

`@invoice = current_user.invoices.find(params[:invoice_id])`

Then, @line will be loaded

`@line = @invoice.lines.find(params[:line_id])`

Then, finally the @charge will be loaded

`@charge = @line.charges.find(params[:id])`

It's called "poor man's access control" because if a user attempts to hack the URL by passing ids for objects they don't own--- which Rails makes relatively easy with its default URL pattern-- they will hit ActiveRecord not found errors (the objects they don't own won't be found in the associated relationship).

It works, but it isn't granular. As well, it isn't appropriate for a large app with any level of intricacy to access control (that is, having roles).

Your customers can delete their own objects by default (may be a good idea or a bad idea for you). If you don't want that, you should strip out the delete actions off the controllers.


### `--auth=`

By default, it will be assumed you have a `current_user` for your user authentication. This will be treated as the "authentication root" for the "poor man's auth" explained above.

The poor man's auth presumes that object graphs have only one natural way to traverse them (that is, one primary way to traverse them), and that all relationships infer that a set of things or their descendants are granted access to me for reading, writing, updating, and deleting.

Of course this is a sloppy way to do access control, and can easily leave open endpoints your real users shouldn't have access to.

When you display anything built with the scaffolding, we assume the `current_user` will have `has_many` association that matches the pluralized name of the scaffold. In the case of nesting, we will automatically find the nested objects first, then continue down the nest chain to find the target object. In this way, we know that all object are 'anchored' to the logged-in user.

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

Please note that this example would product non-functional code, so you would need to manually fix your controllers to make sure `current_account` is available to the controller.


### `--plural=`

You don't need this if the pluralized version is just + "s" of the singular version. Only use for non-standard plurlizations, and be sure to pass it as TitleCase (as if you pluralized the model name which is non-standard for Rails)


### `--exclude=`
(separate field names by COMMA)

By default, all fields are included unless they are on the exclude list. (The default for the exclude list is `id`, `created_at`, and `updated_at`  so you don't need to exclude those-- they are added.)

If you specify an exclude list, those and the default excluded list will be excluded.


`rails generate hot_glue:scaffold Account --exclude=password`

(The default excluded list is: :id, :created_at, :updated_at, :encrypted_password, :reset_password_token, :reset_password_sent_at, :remember_created_at, :confirmation_token, :confirmed_at, :confirmation_sent_at, :unconfirmed_email. If you want to edit any fields with the same name, you must use the include flag instead.)


### `--include=`
Separate field names by COMMA

If you specify an include list, it will be treated as a whitelist: no fields will be included unless specified on the include list.

`rails generate hot_glue:scaffold Account --include=first_name,last_name,company_name,created_at,kyc_verified_at`

Separate COLUMNS by a COLON
If you want to group up fields together into columns, use a COLON (`:`) character to specify columns.
Your input may have a COLON at the end of it, but otherwise your columns will made flush left.

Without colons, no group will happen, so these two fields would display in two columns:
`--include=api_id,api_key`

With a trailing colon, you're telling Hot Glue to make the two fields into column #1. (Here, there is no other column.)
`--include=api_id,api_key:`

If, for example, you wanted to put the `name` field into column #1 and then the api_id and api_key into column #2, you would use:
`--include=name:api_id,api_key`

Specifying any colon in your include syntax switches the builder into 12-column mode, whereas without you might create more than 12 columns if there are too many feilds for the available columns on the layout.

You may not specify both include and exclude.


### `--show-only=`
(separate field names by COMMA)

Any fields only the 'show-only' list will appear as non-editable on the generate form. (visible only)

IMPORTANT: By default, all fields that begin with an underscore (`_`) are automatically show-only.

I would recommend this for fields you want globally non-editable by users in your app. For example, a counter cache or other field set only by a backend mechanism.

### `--stimulus_syntax=true` or `--stimulus_syntax=false`
(for Rails <=6, default is false. For Rails 7, default is true.)

Stimulus is only used for the delete button's confirmation dialog.

If you don't have stimulus syntax enabled, your delete buttons have this. This will confirm the delete with a simple alert if you have UJS enabled.

```
{confirm: 'Are you sure?'}
```

If you do have Stimulus syntax enabled, your delete buttons will look like so:
```
    ## TODO: fix this
```



### `--magic-buttons` (Version 0.4.0 only)
If you pass a list of magic buttons (separated by commas), they will appear in the button area on your list.

It will be assumed there will be cooresponding bang methods on your models.

The band methods can respond in one of four ways:

• With true, in which case a generic success message will be shown in the flash notice (“Approved” or “Rejected” in this case)

• With false, in which case a generic error message will be shown in the flash alert (“Could not approve…”)

• With a string, which will be assumed to be a “success” case, and will be passed to the front-end in the alert notice.

• Raise an ActiveRecord exception

This means you can be a somewhat lazy about your bang methods, but keep in mind the truth operator compares boolean true NOT any object is truth. So your return object must either be actually true (boolean), or an object that is string or string-like (responds to .to_s). Want to just say it didn’t work? Return false. Want to just say it was OK? Return true. Want to say it was successful but provide a more detailed response? Return a string.

Finally, you can raise an ActiveRecord error which will also get passed to the user, but in the flash alert area

For more information see Example 5 in the Tutorial


### `--downnest`

Automatically create subviews down your object tree. This should be the name of a has_many relationship based from the current object.
You will need to build scaffolding with the same name for the related object as well.
On the list view, the object you are currently building will be built with a sub-view list of the objects related from the given line.




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

Omits list action. Only makes sense to use this if you are create a view where you only want the create button you want to navigate to the update screen alternative ways.

### `--no-create`

Omits create action.

### `--no-delete`

Omits delete action.

### `--big-edit`

If you do not want inline editing of your list items but instead to fall back to full page style behavior for your edit views, use `--big-edit`. Turbo still handles the page interactions, but the user is taken to a full-screen edit page instead of an edit-in-place interaction.

### `--display-list-after-update` (default: false)

After an update-in-place normally only the edit view is swapped out for the show view of the record you just edited.

Sometimes you might want to redisplay the entire list after you make an update (for example, if your action removes that record from the result set).

To do this, use flag `--display_list_after_update`. The update will behave like delete and re-fetch all the records in the result and tell Turbo to swap out the entire list.

### `--smart-layout` (default: false)




## Automatic Base Controller

HotGlue will copy a file named base_controller.rb to the same folder where it tries to create any controller, unless such a file exists there already.

Obviously, the created controller will always have this base controller as its subclass. In this way, you are encouraged to implement functionality common to the *namespace* (shared between the controllers in the namespace), using this technique.

## Field Types Supported

- Integers that don't end with `_id`, they will be displayed as text fields.
- Integers that do end with `_id` will be treated automatically as associations. You should have a Rails association defined. (Hot Glue will warn you if it can't find one.)
- String*
- Text*
- Float*
- Datetime
- Date
- Time
- Boolean
- Enum - will display as a value list populated from the enum list defined on your model. see https://jasonfleetwoodboldt.com/courses/stepping-up-rails/enumerated-types-in-rails-and-postgres/

* shows in a size-aware container, i.e. in a bigger box if the field allows for more content



# VERSION HISTORY


#### 2022-12-30 - v0.4.2

#### 2021-12-15 - v0.4.1

#### 2021-12-12 - v0.4.0

#### 2021-12-12 - v0.3.9 - Magic Buttons


#### 2021-12-11 - v0.3.5 - Downnesting


#### 2021-11-27 - v0.2.9E   — EXPERIMENTAL
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

#### 2021-09-27  - v0.2.2 - Fixes some issues with related fields; unlocks Rails 7 in Gemspec file

#### 2021-09-20  - v0.2.1 - Fixes nesting behavior when using gd option

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

SETUP:
• Run bundle install
• if you can't get through see https://stackoverflow.com/questions/68050807/gem-install-mimemagic-v-0-3-10-fails-to-install-on-big-sur/68170982#68170982


The dummy sandbox is found at `spec/dummy`

The dummy sandbox lives as mostly checked- into the repository, **except** the folders where the generated code goes (`spec/dummy/app/views/`, `spec/dummy/app/controllers/`, `spec/dummy/specs/` are excluded from Git)

When you run the **internal specs**, which you can do **at the root of this repo** using the command `rspec`, a set of specs will run to assert the generators are erroring when they are supposed to and producing code when they are supposed to.

The DUMMY testing DOES NOT test the actual functionality of the output code (it just tests the functionality of the generation process).


# DATABASE

`cd spec/dummy`
`rails db:drop`
`rails db:create`
`rails db:migrate`
`RAILS_ENV=test rails db:migrate`

`cd ../..`

take note that when running the spec at the root of the repo you are initializing the Dummy app, which will use the 
SQLite database in spec/dummy/database/


