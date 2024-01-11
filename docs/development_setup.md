# Development Setup

For development, this app uses [Foreman](https://github.com/ddollar/foreman) to kick off both Rails and Tailwind CSS. Use `bin/dev` to start the app using Foreman. This app leverages binstubs, so many of the gem-specific utilities are found under the `bin/` directory.

## Tests

As of now, tests live in Minitest and RSpec. Eventually they'll all be ported to Minitest, but aren't _yet_. So, running both `bin/rspec` and `bin/rails test` will capture all relevant tests.

## Getting Slack to talk to

The development environment is setup to check `NGROK_DOMAIN` for a host when starting up, so if you want Slack to be able to talk to a locally running version of Double Up, [ngrok](https://ngrok.com/) is your friend.

Once installed and logged in, you can create a tunnel for Double Up with `ngrok http 3000`. That will output some useful information, but the Forwarding section is what you'll care about for starting Double Up. Copy that URL (without the protocol) and then start Double Up with

```bash
$ NGROK_DOMAIN=1fa7-63-99-55-76.ngrok.io bin/dev
```

That domain is an example and not any actual running agent. Use your domain instead.
