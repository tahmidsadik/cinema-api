defmodule CinemaApi.Cineplex.Fetcher do
  @moduledoc """
  Fetches the movie showtimes currently premiering in CineplexBD
  """

  import Enum, only: [map: 2]

  def get_movie_times(parsed_html_body) do
    parsed_html_body
    |> Floki.find(".col-lg-8 .col-xs-12")
    |> map(fn n -> Floki.find(n, ".items-wrap") end)
    |> map(fn n ->
      map(n, fn x ->
        x
        |> Floki.find("li")
        |> Floki.text()
        |> String.trim()
        |> String.replace(" ", "")
        |> String.replace("\n", " ")
      end)
    end)
  end

  def get_movie_dates(parsed_html_body) do
    parsed_html_body
    |> Floki.find(".date-tx")
    |> map(fn n -> n |> Floki.find("strong") |> Floki.text() end)
  end

  def get_movie_names(parsed_html_body) do
    parsed_html_body
    |> Floki.find(".col-lg-8 .col-xs-12")
    |> map(fn block -> Floki.find(block, ".text-info") end)
    |> map(fn n -> map(n, fn x -> Floki.text(x) end) end)
    |> map(fn n ->
      map(n, fn x ->
        x
        |> String.trim()
        |> String.replace("\n", "")
      end)
    end)
  end

  @doc """
  Saves the markup in disk for later uses. 
  """
  def save_markup_file(content) do
    {:ok, file} = File.open("./priv/static/cine_info.html", [:write, :utf8])
    IO.write(file, content)
    File.close(file)
  end

  @doc """
  Gets cineplex movie markup from their website.
  The timeouts are extended to 15 second cause sometimes it takes 
  that long for their servers to respond.
  """
  def get_markup_from_network() do
    url = "http://www.cineplexbd.com/cineplexbd/showtime"
    headers = []
    options = [timeout: 15_000, recv_timeout: 15_000]

    case HTTPoison.get(url, headers, options) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        save_markup_file(body)
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:err, "Couldn't find the requested resource"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts(reason)
        {:err, reason}
    end
  end

  @doc """
  fetches cineplex movies markup. Saves the downloaded markup for later use.
  """
  def get_markup() do
    case File.exists?("./priv/static/cine_info.html") do
      true -> File.read("./priv/static/cine_info.html")
      false -> get_markup_from_network()
    end
  end
end
