# Pingo [![Gem Version](https://badge.fury.io/rb/pingo.svg)](http://badge.fury.io/rb/pingo) [![Code Climate](https://codeclimate.com/github/Kyuden/pingo/badges/gpa.svg)](https://codeclimate.com/github/Kyuden/pingo)

Pingo provide a scatterbrain with a `pingo` command of sounding your iphone.

## Installation

Add this line to your application's Gemfile:

    gem 'pingo'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pingo

## Usage

Set APPLE_ID and APPLE_PASSWORD in environment variables. 

```bash
# Set it in .zshrc, .bashrc etc...
echo "export APPLE_ID=your_apple_id" >> ~/.zshrc
echo "export APPLE_PASSWORD=your_apple_password" >> ~/.zshrc
source ~/.zshrc
```

Execute `pingo` command with iphone model name

```bash
pingo your_iphone_model_name
```

Example:

```
# when iphone 5s
pingo 5s
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/pingo/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
