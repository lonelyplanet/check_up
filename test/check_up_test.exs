defmodule CheckUpTest do
  use ExUnit.Case, async: true
  use Plug.Test

  doctest CheckUp


  @standard_opts CheckUp.init(
    service_id: "some-id",
    repo_name: "repo-name",
    contact_info: %{
      slack_channel: "some-slack-channel",
      service_owner_slack_id: "@developer-handle"
    },
    dependencies: []
  )

  test "that it works" do
    conn = conn(:get, "/health-check") |> CheckUp.call(@standard_opts)
    resp = conn.resp_body |> Poison.Parser.parse!

    assert conn.state == :sent
    assert conn.status == 200
    assert resp["links"]["self"] == "http://www.example.com/health-check"
    assert resp["data"]["id"] == "some-id"
    assert resp["data"]["type"] == "op-service"
    assert resp["data"]["attributes"]["contact-info"]["service-owner-slackid"] == "@developer-handle"
    assert resp["data"]["attributes"]["contact-info"]["slack-channel"] == "some-slack-channel"
    assert resp["data"]["attributes"]["github-repo-name"] == "repo-name"
    assert resp["data"]["attributes"]["lp-service-group-id"] == "open-planet"
    assert resp["data"]["attributes"]["lp-service-id"] == "some-id"
    assert resp["data"]["attributes"]["github-commit"] == "ENV NOT SET!"
    assert resp["data"]["attributes"]["docker-image"] == "ENV NOT SET!"
    assert resp["data"]["relationships"] == %{"dependencies" => %{"data" => []}}
  end
end
