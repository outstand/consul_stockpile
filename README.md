# Consul Stockpile

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'consul_stockpile'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install consul_stockpile

## Usage

(On AWS)
`docker run -d --net=host outstand/consul_stockpile start -b bucket -n backup`

## Development

- `docker volume create --name fog`
- `docker build -t outstand/consul_stockpile .`
- `docker run -it --rm --net=host -v $(pwd):/consul_stockpile -v fog:/fog -e FOG_LOCAL=true outstand/consul_stockpile start -b bucket -n backup`

To release a new version:
- Update the version number in `version.rb` and commit the result.
- `docker build -t outstand/consul_stockpile .`
- `docker run -it --rm -v ~/.gitconfig:/consul_stockpile/.gitconfig -v ~/.gitconfig.user:/consul_stockpile/.gitconfig.user -v ~/.ssh/id_rsa:/root/.ssh/id_rsa -v ~/.gem:/root/.gem outstand/consul_stockpile rake release`
- `docker build -t outstand/consul_stockpile:VERSION -f Dockerfile.release .`
- `docker push outstand/consul_stockpile:VERSION`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/outstand/consul_stockpile.

