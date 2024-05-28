<a href="https://www.nylas.com/">
    <img src="https://brand.nylas.com/assets/downloads/logo_horizontal_png/Nylas-Logo-Horizontal-Blue_.png" alt="Aimeos logo" title="Aimeos" align="right" height="60" />
</a>

# Nylas Ruby SDK (Legacy/API v2)

This is the legacy version of the Nylas Ruby SDK, which supports the Nylas API v2. This version of the SDK is currently in maintenance mode and is supported for the purpose of assisting with migration to the new API v3. We recommend migrating and using the current [Nylas Ruby SDK](https://www.github.com/nylas/nylas-ruby) for the latest and greatest features.

## ⚙️ Install
### Prerequisites
- Ruby 2.3 or above.
- Ruby Frameworks: `rest-client`, `json`, `yajl-ruby`.

We support Rails 4.2 and above. A more detailed compatibility list can be found in our [list of Gemfiles](https://github.com/nylas/nylas-ruby/tree/master/gemfiles).

### Install

Add this line to your application's Gemfile:

```ruby
gem 'nylas-legacy'
```

And then execute:

```bash
bundle
```

To run scripts that use the Nylas Ruby SDK, install the nylas gem.

```bash
gem install nylas-legacy
```

To install the SDK from source, clone this repo and install with bundle.

```bash
git clone https://github.com/nylas/nylas-ruby-legacy.git && cd nylas-ruby-legacy
bundle install
```

### Setup Ruby SDK for Development

Install [RubyGems](https://rubygems.org/pages/download) if you don't already have it:

```shell
gem install bundler
gem update --system
```

Install the SDK from source

```shell
bundle install
```

You can run tests locally using ```rspec```:

```shell
rspec spec
```
    
### MacOS 10.11 (El Capitan) Note

Apple stopped bundling OpenSSL with MacOS 10.11. However, one of the dependencies of this gem (EventMachine) requires it. If you're on El Capitan and are unable to install the gem, try running the following commands in a terminal:

```bash
sudo brew install openssl
sudo brew link openssl --force
gem install nylas-legacy
```

## ⚡️ Usage

To use this SDK, you first need to [sign up for a free Nylas developer account](https://nylas.com/register).

Then, follow our guide to [setup your first app and get your API access keys](https://docs.nylas.com/docs/get-your-developer-api-keys).

All of the functionality of the Nylas Communications Platform is available through the `API` object. To access data for an account that’s connected to Nylas, create a new API client object and pass the variables you gathered when you got your developer API keys. In the following example, replace `CLIENT_ID`, `CLIENT_SECRET`, and `ACCESS_TOKEN` with your values.


```ruby
require 'nylas'

nylas = Nylas::API.new(
    app_id: CLIENT_ID,
    app_secret: CLIENT_SECRET,
    access_token: ACCESS_TOKEN
)
```

Now, you can use `nylas` to access full email, calendar, and contacts functionality. For example, here is how you would print the subject line for the most recent email message to the console.


```ruby
message = nylas.messages.first
puts(message.subject)
```

To learn more about how to use the Nylas Ruby SDK, please refer to our [Ruby](https://docs.nylas.com/docs/quickstart-ruby) [SDK QuickStart Guide](https://docs.nylas.com/docs/quickstart-ruby).

## 💙 Contributing

Please refer to [Contributing](Contributing.md) for information about how to make contributions to this project. We welcome questions, bug reports, and pull requests.

Taking part in Hacktoberfest 2023 (i.e. issue is tagged with `hacktoberfest`)? Read our [Nylas Hacktoberfest 2023 contribution guidelines](https://github.com/nylas-samples/nylas-hacktoberfest-2023/blob/main/readme.md).

## 📝 License

This project is licensed under the terms of the MIT license. Please refer to [LICENSE](LICENSE.txt) for the full terms. 
