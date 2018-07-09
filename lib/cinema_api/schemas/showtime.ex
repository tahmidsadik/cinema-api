@moduledoc """
provides schema for the Movie Showtimes
"""
defmodule CinemaApi.Schemas.Showtime do
  import Ecto.Changeset
  use Ecto.Schema

  schema "showtimes" do
    field(:movie_tilte, :string)
    field(:showdate, :date)
    field(:showtime, :time)
    field(:cinema_hall, :string)
  end

  def changeset(showtime, attr) do
    showtime
    |> cast(attrs, [
      :movie_title,
      :showdate,
      :showtime,
      :cinema_hall
    ])
  end
end
