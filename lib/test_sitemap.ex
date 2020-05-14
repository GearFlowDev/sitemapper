defmodule Mix.Tasks.Sitemap do
  @moduledoc false
  @shortdoc "Generate sitemap.xml files for the site"
  use Mix.Task

  require IEx
  alias Gf.Repo
  alias Sitemapper.URL

  @impl true
  def run([]) do
    Mix.Task.run("app.start", [])
    Logger.configure(level: :debug)

    generate_products_sitemap()

    IO.puts("Sitemap Created!")
  end

  def generate_products_sitemap() do
    # Create the sitemap directory if it does not exist
    path = File.cwd!() |> Path.join("tmp")
    File.mkdir_p!(path)

    config = [
      store: Sitemapper.FileStore,
      store_config: [path: path],
      sitemap_url: "https://gearflow.com/sitemap",
      gzip: false
    ]

    Stream.concat([1..100_001])
    |> Stream.map(fn i ->
      %Sitemapper.URL{
        loc: "http://example.com/page-#{i}",
        changefreq: :daily,
        lastmod: Date.utc_today(),
        priority: 1
      }
    end)
    |> Sitemapper.generate(config)
    |> Sitemapper.persist(config)
    |> Enum.to_list()

    # Repo.transaction(fn ->
    #   Gf.Catalog.Product
    #   |> Repo.stream()
    #   |> Repo.stream_preload(500,
    #     store: []
    #   )
    #   |> Stream.map(fn product ->
    #     %URL{
    #       loc:
    #         "https://gearflow.com" <>
    #           GfWeb.Router.Helpers.product_path(
    #             GfWeb.Endpoint,
    #             :show,
    #             product.store.slug,
    #             product.slug
    #           ),
    #       lastmod: product.updated_at
    #     }
    #   end)
    #   |> Sitemapper.generate(config)
    #   |> Sitemapper.persist(config)
    #   # |> Sitemapper.ping(config)
    #   |> Enum.to_list()
    # end)
  end
end
