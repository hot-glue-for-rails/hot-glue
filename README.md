# Hot Glue

Hot Glue is an evolution of the best of the admin-style scaffold builders of the 2010s ([activeadmin](https://github.com/activeadmin/activeadmin), [rails_admin](https://github.com/sferik/rails_admin), and [active_scaffold](https://github.com/activescaffold/active_scaffold) being the most popular of those). It harnesses the power of Rails 6, Turbo-Rails, and Hotwire to deliver a lightning fast experience.

As well, its premise is a little different than the configuration-heavy admin interface toolkits. It will read your relationships and field types to generate your code for you, leaving you with a 'sourdough starter' to work from. If you modify the generated code, you're on your own if you want to preserve your changes and also re-generate scaffold after adding fields. 

It gives users full control over objects they 'own' and by default it spits out functionality giving access to all fields. 

Hot Glue generates functionality that's quick and dirty. It let's you be crafty. As with a real glue gun, take care not to burn yourself while using it. 

* Build plug-and-play scaffolding mixing HAML and turbo_stream responses
* Automatically Reads Your Models (make them before building your scaffolding!)
* CRUD, lists with pagination, (coming soon: sorting & searching)
* Wonderful for prototyping.
* Nest your routes model-by-model for built-in poor man's authentication.
* Plays nicely with Devise, but you can implement your own current_user object instead.
* Requires & uses Kaminari for pagination.
* Create specs automatically along with the controllers (* rspec only for now).
* Throw the scaffolding away when your app is ready to graduate to its next phase (or don't if you like it).

## QUICK START (COMING SOON)

It's really easy to get started by following along with this blog post that creates three simple tables (User, Event, and Format).

Feel free to build your own tables when you get to the sections for building the 'Event' scaffold:

https://blog.jasonfleetwoodboldt.com/hot-glue

## HOW EASY?


```
rails generate hot_glue:scaffold Thing 
```

## TO INSTALL

- Add Turbo-Rails to your Gemfile & bundle install, then install it with `rails turbo:install`

- The Turbo install has switched your action cable settings from 'async' to Redis, so be sure to start a redis server
  
- Add hot_glue to your Gemfile & bundle install, then install it with `rails generate hot_glue:install`

- Add to your `application.html.erb`
```
  <%= render partial: 'layouts/flash_notices' %>
```

- Install Bootstrap (optional)

Bootstrap with Webpack: 
  - change `stylesheet_link_tag` to `stylesheet_pack_tag` in your application layout
  - `yarn add bootstrap`
  - create a new file at `app/javascript/css/site.scss` with this content
    ```
    @import "~bootstrap/scss/bootstrap.scss";
    ```
    
  - add to `app/javascript/packs/application.js` 
    ```
    import 'css/site'
    ```
    
Bootstrap with Sprockets:
  - use bootstrap-rails gem 
    

- Install Devise or implement your own authentication



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

It's called "poor man's auth" because if a user attempts to hack the URL by passing ids for objects they don't own--- which Rails makes relatively easy with its default URL pattern-- they will hit ActiveRecord not found errors (the objects they don't own won't be found in the associated relationship).

It works, but it isn't granular. As well, it isn't appropriate for a large app with any level of intricacy to access control (that is, having roles).

Your customers can delete their own objects by default (may be a good idea or a bad idea for you). If you don't want that, you should strip out the delete actions off the controllers.


### `--auth=`

By default, it will be assumed you have a `current_user` for your user authentication. This will be treated as the "authentication root" for the "poor man's auth" explained above.

The poor man's auth presumes that object graphs have only one natural way to traverse them (that is, one primary way to traverse them), and that all relationships infer that a set of things or their descendants are granted access to me for reading, writing, updating, and deleting.

Of course this is a sloppy way to do authentication, and can easily leave open endpoints your real users shouldn't have access to.

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

You don't need this if the pluralized version is just + "s" of the singular version. Only use for non-standard plurlizations, and be sure to pass it as TitleCase (as if  you pluralized the model name)


### `--exclude=`
(separate field names by COMMA)

By default, all fields are included unless they are on the exclude list. (The default for the exclude list is `id`, `created_at`, and `updated_at`  so you don't need to exclude those-- they are added.)

If you specify an exclude list, those fields + id, created_at, and updated_at will be excluded.



### `--god` or `--gd`

Use this flag to create controllers with no root authentication. You can still use an auth_identifier, which can be useful for a meta-leval authentication to the controller.

For example, FOR ADMIN CONTROLLERS ONLY, supply a auth_identifier and use `--god` flag. 

In God mode, the objects are loaded directly from the base class (these controllers have full access)
```
def load_thing
    @thing = Thing.find(params[:id])
end

```

## FLAGS (Options with no values)
These options (flags) also uses `--` syntax but do not take any values. Everything is assumed (default) to be false unless specified.

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




# VERSION HISTORY

#### 2021-03-01 - v0.0.4 - Validation magic; refactors the options to the correct Rails::Generators syntax

#### 2021-02-27 - v0.0.3 - several fixes for namespaces; adds pagination; adds exclude list to fields

#### 2021-02-25 - v0.0.2 - bootstrapy

#### 2021-02-24 - v0.0.1 - first proof of concept release -- basic CRUD works 

#### 2021-02-23 - v0.0.0 - Port of my prior work from github.com/jasonfb/common_core_js


# ACKNOWLEDGEMENTS

### "POOR MAN"

I hope one day I will leave this Earth a poor man (like my code) owning only the most simple structure for the simple form of my existence. Thanks for having educated me in this wisdom goes to my former mentor [@trak3r](https://github.com/trak3r)! 




# HOW THIS GEM IS TESTED

The testing of functionality-within-functionality is a little tricky and requires thinking outside the box.

We have two kinds of "sandboxes": a DUMMY sandbox, and also a STRAWMAN sandbox

The dummy sandbox is found at `spec/dummy`

The dummy lives as mostly checked- into the repository, except the folders where the generated code goes (`spec/dummy/app/views/`, `spec/dummy/app/controllers/`, `spec/dummy/specs/` are excluded from Git)

When you run the **internal specs**, which you can do **at the root of this repo** using the command `rspec`, a set of specs will run to assert the generators are erroring when they are supposed to and producing code when they are supposed to.


The DUMMY testing DOES NOT test the actual functionality of the output code (it just tests the functionality of the generation process).

For this reason, I've also added something I call STRAWMAN testing, which is a set of steps that does these things:

The Strawman isn't in the repository, but if you build it locally, it will create itself into

`spec/strawman/`

1) Builds you a strawman sandbox app from scratch, using the native `rails new`
2) Makes a few small modifications to the new app to support this gem
3) Create two nonsense tables called OmnitableA and OmnitableB. Each omnitable has one of each kind of field (integer, text, string, date, time, etc)
4) In this way, it is a "Noah's Arc" testing strategy: It will build you a fully functional app using all of the feature sets of the gem.
5) The built app itself will contain its own specs
6) You will then cd into `spec/strawman` and run `rspec`. This second test suite now runs to full test all of the *generated* code. 


