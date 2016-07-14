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

- `docker volume create --name consul_stockpile_fog`
- `./build_dev.sh`
- `docker run -it --rm --net=host -v $(pwd):/consul_stockpile -v consul_stockpile_fog:/fog -e FOG_LOCAL=true outstand/consul_stockpile:dev start -b bucket -n backup`

To release a new version:
- Update the version number in `version.rb` and `Dockerfile.release` and commit the result.
- `./build_dev.sh`
- `docker run -it --rm -v ~/.gitconfig:/root/.gitconfig -v ~/.gitconfig.user:/root/.gitconfig.user -v ~/.ssh/id_rsa:/root/.ssh/id_rsa -v ~/.gem:/root/.gem outstand/consul_stockpile:dev rake release`
- `docker build -t outstand/consul_stockpile:VERSION -f Dockerfile.release .`
- `docker push outstand/consul_stockpile:VERSION`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/outstand/consul_stockpile.

