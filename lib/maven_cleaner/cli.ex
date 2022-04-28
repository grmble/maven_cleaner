defmodule MavenCleaner.CLI do
  @moduledoc """
  Maven Cleaner CLI Module

  """

  alias Filetree2.Filter
  require Logger

  @spec main([String.t()]) :: :ok
  @doc """
  Clean up maven repository.

  Without arguments, it will use $HOME/.m2.

  If a directory is given, that will be cleaned.
  """
  def main([]), do: main([find_maven_respository()])

  def main([dir]) do
    clean(dir)
  end

  @spec find_maven_respository :: String.t()
  def find_maven_respository() do
    System.user_home()
    |> Path.join(".m2")
    |> Path.join("settings.xml")
    |> MavenCleaner.Settings.repository!()
  end

  @spec clean(path) :: :ok when path: Path.t()
  def clean(path) do
    Logger.info("cleaning #{path}")

    Filetree2.stream(path,
      type: :regular,
      dotfiles: :keep,
      match: ~R/SNAPSHOT/,
      older_than: {2, :month}
    )
    |> Stream.map(fn {:ok, path, stat} -> {stat.size, path} end)
    |> Enum.reduce(0, fn {size, path}, sum ->
      Logger.debug("deleting#{path}: #{size}")

      case File.rm(path) do
        :ok -> sum + size
        _ -> sum
      end
    end)
    |> then(&Logger.info("deleted #{&1} bytes"))

    Filetree2.stream(path, type: :regular, dotfiles: :keep)
    |> Stream.filter(fn {:ok, _, stat} -> stat.size == 0 end)
    |> Stream.map(&Filter.only_path/1)
    |> Enum.each(fn path ->
      Logger.info("removing empty file #{path}")
      File.rm(path)
    end)

    Filetree2.empty_dirs2(path)
    |> Enum.each(fn path ->
      Logger.debug("removing empty directory: #{path}")
      File.rmdir(path)
    end)

    Logger.info("Biggest remaining files:")

    Filetree2.stream(path, type: :regular, dotfiles: :keep)
    |> Stream.map(fn {:ok, path, stat} -> {stat.size, path} end)
    |> Enum.sort(:desc)
    |> Enum.take(20)
    |> Enum.each(fn {size, path} ->
      Logger.info("#{size} #{path}")
    end)

    :ok
  end
end
