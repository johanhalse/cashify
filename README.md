[![Main](https://github.com/johanhalse/multicash/actions/workflows/main.yml/badge.svg)](https://github.com/johanhalse/multicash/actions/workflows/main.yml)

# Multicash

Ever had to work with money in more than one currency? Ever wish you could do stuff like add them to one another without getting murdered by exceptions? Here's the gem for you.

![Multicash](https://media4.giphy.com/media/EnoO73pTnn99JrnRR3/giphy.gif)

## Installation

Add this line to your application's Gemfile:

```ruby
gem "multicash"
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install multicash

## Usage

Multicash is a money handling gem that's inherently nice to currencies. It anticipates some cool things you might want to do to your various piles of money. You can instantiate a new `Cash` object like so:

```ruby
puts Cash.new(SEK: 100_00)
# 100 SEK
```

Add another currency? Sure.

```ruby
puts Cash.new(EUR: 100_00, SEK: 100_00)
# 100 EUR, 100 SEK
```

And then maybe do some addition or subtraction?

```ruby
puts Cash.new(SEK: 100_00) + Cash.new(USD: 100_00) + Cash.new(USD: 50_00)
# 100 SEK, 150 USD
```

Perhaps add a little discount here or there?

```ruby
puts (Cash.new(SEK: 100_00) + Cash.new(USD: 100_00)) * 0.9
# 90 SEK, 90 USD
```

Increase the values a little? Why not!

```ruby
puts (Cash.new(SEK: 100_00, USD: 100_00) + 20
# 120 SEK, 120 USD
```

### What. You can't just add integers to currencies

I can, in fact, totally add integers to currencies. And now you can, too! Also subtract, divide, multiply... look: this probably sounds bad to you. Foreign, somehow. Your parents raised you well, and you've already used the ubiquitous [Money](https://github.com/RubyMoney/money) gem and tried to add a shipping cost or something. The Money gem then told you to stop immediately and stomped off into Exception Land, leaving you empty-handed and full of regret.

Or maybe you wanted to work with zero? The Money gem acts a little weird around zero, too. You'll get answers on the Internet saying things like "aha but what would zero even mean when using a currency" and my answer to that would be "well at least 0 USD is the same as 0 SEK, right?" and so you can casually do `Cash.new(SEK: 0) + Cash.new(USD: 100)` and get `100 USD` back and then imagine these pedants popping a vein and dying. A zero is a zero, right? Damn straight. Don't try to tell me otherwise.

### Can you _really_ compare currencies that way though?

Well, I guess we can! And we're not even done. Check this out:

```ruby
Cash.new(SEK: 100_00) > Cash.new(USD: 50_00)
# true
```

Is this right or wrong? Who even knows at this point. But it's _useful_, and that's all we care about! I'll agree that the comparison is super naive, and you can Freedom Patch that if you like, or go the Money Gem route and pipe those objects through your own functions. But you see where we're going, right? Wouldn't it be nice to just grab various sums of currencies from your database, cast them to Cash objects, and have them just sort of _work_ without putting up guardrails everywhere? Yes it would. The default assumption of "when you try to add one money to another money that probably means you want a conversion somewhere" is wrong in most cases. Also, initialization matters! Multicash is very database friendly. Imagine a Rails app with `Purchase` objects that all have a cost. Then look at this beauty:

```ruby
Cash.new Purchase.all.group(:cost_currency).sum(:cost_cents)
```

That piece of code pulls _however many objects in however many currencies_ and tallies them up in SQL, returning a useful Cash object containing something along the lines of `1100 EUR, 1400 SEK, 2155 USD`. If you want, you can smack a multiplier on those and add a discount. Or add a processing fee of `100 SEK`. You be the boss.

### This sounds dangerous and illegal, shouldn't these operations throw exceptions?

No, they probably shouldn't. The Money Gem school of thought says that every time you do something potentially hazardous to your money — like try to add an integer, not caring which currency you're dealing with — there's an exception, and then you'll have to handle that exception in a way that makes sense for your use case. I do see the logic, but in practice it gets old REAL fast. You'll be stuck in a never-ending shouting match with your money objects, having to drag them kicking and screaming through a bunch of guard statements in order to do simple things like addition. If you're only dealing with a single currency it's not too bad, but as soon as you add another one to the mix the noise level is deafening. And honestly: if you're only dealing with a single currency, why are you even using a money gem? You could use fixed point integers instead, pushing any currency-specific stuff to the boundaries of your code.

This in mind, Multicash posits that if you want to get these things right, you should be treating your money as simple numbers as often as possible. Currencies are a necessary evil but they're not your overarching concern, and this gem will allow them to lurk in the background where they belong. Throw those Cash objects around, stuff them into arrays, collide them in interesting ways. Swim around in your money like you're Scrooge McDuck and let your database do most of the work for you! It'll feel great, I promise.

### Do you handle displaying currencies nicely, too?

Oof, sounds hard. Out of scope. Write a view helper or something.

### And when you actually do want to convert currencies?

There are plenty of gems for that and it's honestly pretty easy. But you'll have to write your own code for it.

## API

#### `.positive?` and `.negative?`

Returns true if all currencies are positive/negative.

```ruby
Cash.new(SEK: 100_00, USD: 100_00).positive?
# true

Cash.new(SEK: 100_00, USD: -1_00).positive?
# false

Cash.new(SEK: -100_00, USD: -100_00).negative?
# true
```

#### `.zero?`

Returns true if all currencies are zero.

```ruby
Cash.new(SEK: 0).zero?
# true

Cash.new(SEK: 0, USD: 1_00).zero?
# false
```

#### `.abs`

Makes all values positive.

```ruby
Cash.new(SEK: -100_00, USD: 1_00).abs
# 100 SEK, 1 USD
```

#### `.zero`

Shorthand for a zero currency. Use it instead of `Cash.new(DKK: 0)` because having to specify currency for zero feels wordy and awkward.

```ruby
Cash.zero
# 0 USD
```

#### `.to_a`

Splits all the currencies out into an array of `Cash` objects.

```ruby
Cash.new(EUR: 100_00, SEK: 100_00, USD: 100_00).to_a
# [Cash(EUR: 100_00), Cash(SEK: 100_00), Cash(USD: 100_00)]
```

#### `.to_s`

Get a simple string back.

```ruby
Cash.new(EUR: 100_00, SEK: 100_00, USD: 100_00).to_s
# "100 EUR, 100 SEK, 100 USD"
```

#### `.sum`

You'll be working with arrays of Cash objects a lot. You should absolutely be using Ruby's excellent array methods on them, but unfortunately `cash_array.sum` won't work. Ruby's `sum` method injects a `0` as the first value, and even though `Cash.new(USD: 100) + 0` is super valid and nice, `0 + Cash.new(USD: 100)` will try to coerce your Cash object into an integer which just won't work. So if you want to sum an array of Cash, you can instead use:

```ruby
Cash.sum [Cash.new(EUR: 100_00), Cash.new(SEK: 100_00), Cash.new(EUR: 100_00)]
# 200 EUR, 100 SEK
```

#### `.empty?`

Returns true if there are no currencies in the object.

```ruby
Cash.new.empty?
# true

Cash.new(NOK: 100_00).empty?
# false
```

#### `.round`

Rounds currencies to a power interval.

```ruby
Cash.new(EUR: 100_50, SEK: 122_25).round(100)
# 101 EUR, 122 SEK

Cash.new(EUR: 100_50, SEK: 122_25).round(1000)
# 100 EUR, 120 SEK
```

#### `.currency`

Returns the first currency in the Cash object as a symbol

```ruby
Cash.new(NOK: 100).currency
# :NOK
```

#### `.value`

Returns the first value in the Cash object.

```ruby
Cash.new(NOK: 100).value
# 100
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/johanhalse/multicash.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
