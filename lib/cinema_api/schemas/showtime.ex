defmodule CinemaApi.Schemas.Showtime do
  @moduledoc """
  provides schema for the Movie Showtimes
  """
  import Ecto.Changeset
  use Ecto.Schema

  schema "showtimes" do
    field(:title, :string)
    field(:imdb_id, :string)
    field(:showtime, :utc_datetime)
    field(:cinemahall, :string)
  end

  def changeset(showtime, attrs) do
    showtime
    |> cast(attrs, [
      :title,
      :imdb_id,
      :showtime,
      :cinemahall
    ])
  end
end
