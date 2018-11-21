defmodule Vapor.Config.File do
  defstruct path: nil, format: nil

  def with_name(name) do
    %__MODULE__{path: name, format: format(name)}
  end

  defp format(path) do
    case Path.extname(path) do
      "" ->
        raise Vapor.FileFormatNotFoundError, path

      ".json" ->
        :json

      ".toml" ->
        :toml

      ".yaml" ->
        :yaml
    end
  end

  defimpl Vapor.Provider do
    def load(%{path: path, format: format}) do
      case File.read(path) do
        {:ok, str} ->
          case format do
            :json ->
              Jason.decode(str)

            :toml ->
              Toml.decode(str)

            :yaml ->
              YamlElixir.read_from_string(str)
          end

        {:error, _} ->
          raise Vapor.FileNotFoundError, path
      end
    end
  end
end
