defmodule CheckUp.Utils do
  def url_from_conn(conn) do
    query = case conn.query_string do
      ""  -> nil
      nil -> nil
      any -> any
    end

    URI.to_string(%URI{path: conn.request_path, query: query})
  end
end
