
[![Build Status](https://app.travis-ci.com/jasonfb/hot-glue.svg?branch=main)](https://travis-ci.com/jasonfb/hot-glue)


Hot Glue is a Rails scaffold builder for the Turbo era. It is an evolution of the admin-interface style scaffolding systems of the 2010s ([activeadmin](https://github.com/activeadmin/activeadmin), [rails_admin](https://github.com/sferik/rails_admin), and [active_scaffold](https://github.com/activescaffold/active_scaffold)). 


Using Turbo-Rails and Hotwire (default in Rails 7) you get a lightning-fast out-of-the-box CRUD building experience. 

Every page displays only a list view: new and edit operations happen as 'edit-in-place', so the user never leaves the page. 

Because all page navigation is Turbo's responsibilty, everything plugs & plays nicely into a Turbo-backed Rails app. 

Alternatively, you can use this tool to create a Turbo-backed *section* of your Rails app-- like an admin interface -- while still treating the rest of the Rails app as an API or building out other features by hand. 

It will read your relationships and field types to generate your code for you, leaving you with a 'sourdough starter' to work from. If you modify the generated code, you're on your own if you want to preserve your changes and also re-generate scaffold after adding fields. 

By default, it generates code that gives users full control over objects they 'own' and by default it spits out functionality giving access to all fields. 

Hot Glue generates functionality that's quick and dirty. It let's you be crafty. As with a real hot glue gun, use with caution. 

* Build plug-and-play scaffolding for any CRUD on any object
* mixes HAML and turbo_stream responses
* Everything edits-in-place (unless you use --big-edit, then it won't)  
* Automatically reads your ActiveRecord models and relationships (make them before building your scaffolding!)
* Create-read-update-delete (CRUD) with pagination (one day: sorting & searching)
* Excellent tool for prototyping and hackathons, but a knowledge of Rails is needed. 
* Nest your routes model-by-model for built-in poor man's access control. (Customers have_many :invoices; Invoices have_many :line_items; etc)
* Plays nicely with Devise, but you can implement your own current_user object instead.
* Kaminari for pagination.
* Create specs automatically along with the controllers.
* Throw the scaffolding away when your app is ready to graduate to its next phase (or don't if you like it).

## QUICK START

It's really easy to get started by following along with this blog post that creates three simple tables (User, Event, and Format).

Feel free to build your own tables when you get to the sections for building the 'Event' scaffold:

https://jasonfleetwoodboldt.com/hot-glue

## HOW EASY?

```
rails generate hot_glue:scaffold Thing 
```

Generate a quick scaffold to manage a table called `pronouns`
![hot-glue-3](https://user-images.githubusercontent.com/59002/116405509-bdee2f00-a7fd-11eb-9723-4c6e22f81bd3.gif)



Instantly get a simple CRUD interface

![hot-glue-4](https://user-images.githubusercontent.com/59002/116405517-c2b2e300-a7fd-11eb-8423-d43e3afc9fa6.gif)

## TO INSTALL (RAILS 7)

- Install Turbo `rails turbo:install` (?)

- Add `gem 'hot-glue'` to your Gemfile
- `bundle install`
- `rails generate hot_glue:install --markup=erb` for ERB
- or `rails generate hot_glue:install --markup=haml` for HAML

- Add to your `application.html.erb`
```
  <%= render partial: 'layouts/flash_notices' %>
```
- Or for Haml add to your `application.haml`
```
    = render partial: 'layouts/flash_notices' 
```

## TO INSTALL (RAILS 6)

- Add `gem 'turbo-rails'` to your Gemfile & `bundle install`
  
- Then install it with `rails turbo:install`

- The Turbo install has switched your action cable settings from 'async' to Redis, so be sure to start a redis server
  
- Add `gem 'hot-glue'` to your Gemfile & `bundle install`
  
- in `javascript/packs/application.js` remove this line:
`import Turbolinks from "turbolinks"`

- in the same file (`javascript/packs/application.js`) add this line:
`import { Turbo } from "@hotwired/turbo-rails"`

- Run the hot-glue install generator 

FOR ERB:
`rails generate hot_glue:install --markup=erb`

FOR HAML:
`rails generate hot_glue:install --markup=haml`

- Add to your `application.html.erb`
```
  <%= render partial: 'layouts/flash_notices' %>
```


## Rspec setup
  - add `gem 'rspec-rails'` to your gemfile inside :development and :test
  - add `gem 'factory_bot_rails'` to your gemfile inside :development and :test
  - more info:
      https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md#rspec

  - add `gem 'ffaker'` to your Gemfile inside the  :development and :test groups
  - 
  - run `rails generate rspec:install`
  - configure Rspec to work with Factory Bot inside of `rails_helper.rb`
    ```
    RSpec.configure do |config|
        // ... more rspec configuration (not shown)
        config.include FactoryBot::Syntax::Methods
    end
    ```  
    
  - add to rails_helper.rb (inside the existing Rspec.configure block)
  -  ````
config.include FactoryBot::Syntax::Methods
````
  - also add to rails_helper.rb (outside of the Rspec.configure block)
    ```
    Capybara.register_driver :headless_chrome_desktop do |app|
      options = Selenium::WebDriver::Chrome::Options.new
      options.add_argument('--headless')
      options.add_argument('--disable-gpu')
      options.add_argument('--window-size=1280,1200')
    
      driver = Capybara::Selenium::Driver.new(app,
                                              browser: :chrome,
                                              options: options)
    
      driver
    end
    Capybara.default_driver = :headless_chrome_desktop
    
    ```
    

  - for a quick Capybara login, create a support helper in `spec/support/` and log-in as your user
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

## Install Bootstrap using Sprockets (IMPORTANT: YOU DO NOT NEED JQUERY*)
Bootstrap with Sprockets for Rails 5 or 7 default — Rails 6 custom
      - use twbs/bootstrap-rubygem gem
      - see README for bootstrap-rubygem to install
Bootstrap with Webpack for FOR RAILS 7 :
          
- add to Gemfile
- gem 'bootstrap', '~> 5.1.0'


- completely delete the file `app/assets/application.css`
- create new file where it was `app/assets/application.scss` with this contents (do not keep the contents of the old application.css file):

``` 
// Custom bootstrap variables must be set or imported *before* bootstrap.
@import "bootstrap";
```

* You do not need jQuery for HotGlue to work *

### Bootstrap with Webpack RAILS 6 ONLY:
- change `stylesheet_link_tag` to `stylesheet_pack_tag` in your application layout
  - run `yarn add bootstrap`
  - create a new file at `app/javascript/require_bootstrap.scss` with this content
    ```
    @import "~bootstrap/scss/bootstrap.scss";
    ```
    
  - add to `app/javascript/packs/application.js` 
    ```
    import 'require_bootstrap'
    ```
  



## Install Devise or implement your own authentication
  (or only use --gd mode, see below)

## install font-awesome. I recommend https://github.com/tomkra/font_awesome5_rails or https://github.com/FortAwesome/font-awesome-sass


### First Argument
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
(separate field names by COMMA)

You may not specify both include and exclude. If you specify an include list, it will be treated as a whitelist: no fields will be included unless specified on the include list. 

`rails generate hot_glue:scaffold Account --include=first_name,last_name,company_name,created_at,kyc_verified_at`


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
    <%= button_to "Delete <i class='fa fa-1x fa-remove'></i>".html_safe, 
        thing_path(branch), method: :delete, 
        data: {
            'controller: 'confirmable', 
            'confirm-message': 'Are you sure you want to delete Thing?', 
            'action': 'confirmation#confirm'
        },  
        disable_with: "Loading...", class: "delete-branch-button btn btn-primary " %>
```

Your install script will output an additional stimulus controller:

```

```



### `--markup` (default: 'erb')

ERB is default. For HAML, `--markup=haml`. 


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


### `--no-create`

Omits create action. 

### `--no-delete`

Omits delete action. 

### `--big-edit`

If you do not want inline editing of your list items but instead to fall back to full page style behavior for your edit views, use `--big-edit`. Turbo still handles the page interactions, but the user is taken to a full-screen edit page instead of an edit-in-place interaction.


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
- Date (TOOD: implement this)
- Time (TOOD: implement this)
- Boolean 
- Enum - will be magically displayed as a value list populated from the enum list defined on your model. see https://jasonfleetwoodboldt.com/courses/stepping-up-rails/enumerated-types-in-rails-and-postgres/
    
* shows in a size-aware container, i.e. in a bigger box if the field allows for more content



# VERSION HISTORY

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

#### (yanked)   - v0.0.4

#### 2021-02-27 - v0.0.3 - several fixes for namespaces; adds pagination; adds exclude list to fields

#### 2021-02-25 - v0.0.2 - bootstrapy

#### 2021-02-24 - v0.0.1 - first proof of concept release -- basic CRUD works 

#### 2021-02-23 - v0.0.0 - Port of my prior work from github.com/jasonfb/common_core_js



# HOW THIS GEM IS TESTED

SETUP:
• Run bundle install
• if you can't get through see https://stackoverflow.com/questions/68050807/gem-install-mimemagic-v-0-3-10-fails-to-install-on-big-sur/68170982#68170982


The dummy sandbox is found at `spec/dummy`

The dummy sandbox lives as mostly checked- into the repository, **except** the folders where the generated code goes (`spec/dummy/app/views/`, `spec/dummy/app/controllers/`, `spec/dummy/specs/` are excluded from Git)

When you run the **internal specs**, which you can do **at the root of this repo** using the command `rspec`, a set of specs will run to assert the generators are erroring when they are supposed to and producing code when they are supposed to.

The DUMMY testing DOES NOT test the actual functionality of the output code (it just tests the functionality of the generation process).

