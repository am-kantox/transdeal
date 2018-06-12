# [![Build Status](https://travis-ci.org/am-kantox/transdeal.svg?branch=master)](https://travis-ci.org/am-kantox/transdeal) Transdeal

This library is supposed to simplify rolling back transactions,
preserving some data still stored.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'transdeal'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install transdeal

## Usage

Somewhere in application intializers:

```ruby
Transdeal.configure do |data|
  puts data.inspect
  TemporaryStorage.store(data)
end
```

and inside the application code:

```ruby
Transdeal.transaction(users.main) do |data|
  users.main = :me
  customers.destroy_all!
  raise ActiveRecord::Rollback
end
```

The above will call a configured backend(s) with the last version of modified
objects before the transaction is rolled back.

### Explicit handlers

```ruby
class CallbackHandler
  def self.run(data)
    puts data.inspect
  end
end

Transdeal.transaction(users.main, callback: :callback_handler) do
  users.main = :me
  raise ActiveRecord::Rollback
end
```

There are two keyword parameters currently accepted:

* `callback` — anything that can be converted to proc, or symbol for the class
  name, or a string, or a class (the class must respond to one of
  `[:store, :run, :perform_async, :perform, :call, :[]]`—tried
  in descending order,) or hash `{receiver: ..., method: ...}`
* `skip_global_callbacks` — the callbacks configured through global
  `Transdeal.configure` method will be skipped.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/am-kantox/transdeal. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Transdeal project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/am-kantox/transdeal/blob/master/CODE_OF_CONDUCT.md).
