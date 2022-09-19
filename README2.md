
## LEGACY SETUP FOR RAILS 6

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

## Legacy Step #4: Postgresql Enum Support for Rail 6
For Enum support, I recommend activerecord-pg_enum
Instructions for Rails 6 are here:
https://jasonfleetwoodboldt.com/courses/stepping-up-rails/enumerated-types-in-rails-and-postgres/

_This functionality is now built-in to Rails 7._


## Legacy Step #5: Fix Devise if adding Turbo To Your Project
## IMPORTANT: Devise currently has serious compatibility issues with Turbo Rails. In particular, your log-in screens do not work out of the box. Follow the next step to fix them.

Manually port the Devise views into your app with

`rails generate devise:views`

Edit `devise/registrations/new`, `devise/sessions/new`, `devise/passwords/new` and `devise/confirmations/new` modifying all four templates like so:

form_for(resource, as: resource_name, url: session_path(resource_name) ) do |f|

add the data-turbo false option in the html key:

form_for(resource, as: resource_name, **html: {'data-turbo' => "false"},** url: session_path(resource_name) ) do |f|

This tells Devise to fall back to non-Turbo interaction for the log-in and registration. For the rest of the app, we will use Turbo Rails interactions.
