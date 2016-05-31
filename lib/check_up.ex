defmodule CheckUp do
  import Plug.Conn
  import CheckUp.Utils

  defstruct service_id: "UNKNOWN",
            dependencies: [],
            contact_info: %{},
            repo_name: "",
            git_commit: "ENV NOT SET!",
            docker_image: "ENV NOT SET!"

  def init(opts) do
    opts = case Keyword.pop(opts, :config) do
      {nil, new_opts} -> new_opts
      {val, new_opts} ->
        Keyword.merge(Application.get_env(val, :health_check), new_opts)
    end
    Map.keys(%__MODULE__{})
    |> Enum.reduce(%__MODULE__{}, fn key, struct ->
      case Keyword.get(opts, key) do
        nil -> struct
        any -> Map.put(struct, key, any)
      end
    end)
  end

  def call(conn, info) do
    check = %{}
    |> add_attributes(info)
    |> add_relations(info)
    |> add_self_link(conn)
    |> handle_include(info, conn.params)
    |> Poison.encode!

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, check)
  end

  defp add_attributes(map, info) do
    Map.put(map, :attributes, %{
      "lp-service-group-id" => "open-planet",
      "lp-service-id" => info.service_id,
      "github-repo-name" => info.repo_name,
      "docker-image" => System.get_env("DOCKER_IMAGE") || info.docker_image,
      "github-commit" => System.get_env("GITHUB_COMMIT") || info.git_commit,
      "contact-info" => %{
        "service-owner-slackid" => info.contact_info[:service_owner_slack_id],
        "slack-channel" => info.contact_info[:slack_channel]
      }
    })
  end

  defp add_self_link(map, conn) do
    map |> Map.put(:links, %{self: url_from_conn(conn)})
  end

  defp add_relations(map, info) do
    dependencies = Enum.map(info.dependencies, &Map.take(&1, [:id, :type]))
    Map.put(map, :relationships, %{ dependencies: %{ data: dependencies } })
  end
  
  defp handle_include(map, info, %{"include"=>"dependencies"}) do
    Map.put(map, :include, Enum.map(info.dependencies, &report_dependency/1))
  end
  defp handle_include(map, _info, _params), do: map

  defp report_dependency(dep = %{repo: repo}) do
    status = test_db_connection(repo)

    dep
    |> Map.take([:id, :type])
    |> Map.put(:attributes, %{
      location: repo.config[:hostname],
      status: status.status,
      description: status.description
    })
  end

  defp test_db_connection(repo) do
    try do
      case Ecto.Adapters.SQL.query!(repo, "SELECT true", []) do
        _ -> %{status: "green", description: "no problems found"}
      end
    rescue
      error in DBConnection.Error ->
        %{status: "red", description: error.message}
      _any ->
        %{status: "red", description: "bad stuff going on"}
    end
  end
end
