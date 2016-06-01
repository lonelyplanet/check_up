# CheckUp

Provides a health-endpoint for plug applications that conforms to the json-api
spec and contains health-check information on your service that systems like
Nagios or AWS Cloudwatch can monitor.

## Usage

#### With a Config

**config.exs**
``` elixir
use Mix.Config

config :your_app_name, :health_check, 

  # The "ID" of your application
  service_id: "some-id",

  # Name of the Repo in Github
  repo_name: "repo-name",

  # Information of who to contact in case of problems
  contact_info: %{
    slack_channel: "some-slack-channel",
    service_owner_slack_id: "@developer-handle"
  },


  # List testable dependencies
  dependencies: [%{
    id: "my-app-db",
    type: "database",
    repo: MyApp.Repo
  }]

```

**router.ex**
``` elixir
# ...

get "/health-check", CheckUp, config: :your_app_name

```

#### Without a Config

**router.ex**
``` elixir
# ...

get "/health-check, CheckUp,

  service_id: "some-id",
  repo_name: "repo-name",
  contact_info: %{
    slack_channel: "some-slack-channel",
    service_owner_slack_id: "@dev" },
  dependencies: [%{
    id: "my-app-db",
    type: "database",
    repo: MyApp.Repo
  }]

```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add check_up to your list of dependencies in `mix.exs`:

        def deps do
          [{:check_up, github: "lonelyplanet/check_up"}]
        end

