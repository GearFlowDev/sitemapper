defmodule Sitemapper.S3Store do
  @behaviour Sitemapper.Store

  def write(filename, body, config) do
    bucket = Keyword.fetch!(config, :bucket)

    props = [
      {:content_type, content_type(filename)},
      {:cache_control, "must-revalidate"},
      {:acl, :public_read}
    ]

    ExAws.S3.put_object(bucket, filename, body, props)
    |> ExAws.request!()

    :ok
  end

  defp content_type(filename) do
    if String.ends_with?(filename, ".gz") do
      "application/x-gzip"
    else
      "application/xml"
    end
  end
end
