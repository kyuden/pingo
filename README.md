# Pingo [![Gem Version](https://badge.fury.io/rb/pingo.svg)](http://badge.fury.io/rb/pingo) [![Code Climate](https://codeclimate.com/github/Kyuden/pingo/badges/gpa.svg)](https://codeclimate.com/github/Kyuden/pingo) [![wercker status](https://app.wercker.com/status/8fc989959ae4630aef746364c6ead94f/m/master "wercker status")](https://app.wercker.com/project/bykey/8fc989959ae4630aef746364c6ead94f)

<p><img width="400"src="http://www.fastpic.jp/images.php?file=8622347177.jpg"></p>
Pingo provide a scatterbrain with a `pingo` command of sounding your iphone.

## Installation

Install it yourself as:

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
# when iphone 6
pingo 6
# when iphone 6 Plus
pingo 6.Plus
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/pingo/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
