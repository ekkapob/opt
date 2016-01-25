defmodule Opt.CourseView do
  use Opt.Web, :view

  def markdown(body) do
    body
    |> Earmark.to_html
    |> raw
  end
end
