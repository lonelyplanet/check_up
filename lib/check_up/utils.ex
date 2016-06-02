defmodule CheckUp.Utils do
  def url_from_conn(conn) do
    scheme = case conn.scheme do
      :http  -> "http"
      :https -> "https"
      _any   -> nil
    end

    query = case conn.query_string do
      ""  -> nil
      nil -> nil
      any -> any
    end

    URI.to_string(%URI{path: conn.request_path, query: query})
  end
end
