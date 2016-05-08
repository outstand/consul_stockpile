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
- Update the version number in `version.rb`
- Run `docker run -it --rm outstand/consul_stockpile:latest bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).
- Run `docker build -t outstand/consul_stockpile:VERSION -f Dockerfile.release .`
- Run `docker push outstand/consul_stockpile:VERSION`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/outstand/consul_stockpile.

