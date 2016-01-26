defmodule Opt.CourseViewTest do
  use Opt.ConnCase, async: true

  test "converts markdown to html" do
    {:safe, result} = Opt.CourseView.markdown("**bold me**")
    assert String.contains? result, "<strong>bold me</strong>"
  end

  test "leaves text with no markdown alone" do
    {:safe, result} = Opt.CourseView.markdown("leave me alone")
    assert String.contains? result, "leave me alone"
  end
end
