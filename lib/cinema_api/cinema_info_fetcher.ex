defmodule CinemaApi.CinemaInfoFetcher do
  import Enum, only: [map: 2]

  def async_task_test do
    urls = [
      "https://google.com",
      "https://www.rust-lang.org/en-US/",
      "https://atom.io",
      "https://code.visualstudio.com"
    ]

    urls
    |> map(fn url -> Task.async(fn -> HTTPoison.get(url) end) end)
    |> map(&Task.await/1)
  end
end
