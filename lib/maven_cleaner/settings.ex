defmodule MavenCleaner.Settings do
  import Record
  defrecord(:xmlElement, extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl"))
  defrecord(:xmlAttribute, extract(:xmlAttribute, from_lib: "xmerl/include/xmerl.hrl"))
  defrecord(:xmlText, extract(:xmlText, from_lib: "xmerl/include/xmerl.hrl"))

  @spec repository!(Path.t()) :: String.t()
  def repository!(settings_file) do
    # error if unparsed input remains
    {doc, []} =
      settings_file
      |> File.read!()
      |> String.to_charlist()
      |> :xmerl_scan.string()

    :xmerl_xpath.string('/settings/localRepository/text()', doc)
    |> hd
    |> xmlText(:value)
    |> List.to_string()
  end
end
