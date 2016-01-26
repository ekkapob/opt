defmodule Opt.CourseTest do
  use Opt.ModelCase

  alias Opt.Course
  import Ecto.Changeset, only: [get_change: 2]

  @valid_attrs %{body: "some content", title: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Course.changeset(%Course{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Course.changeset(%Course{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "when the body includes a script tag" do
    changeset = Course.changeset(%Course{},
      %{@valid_attrs | body: "Hello <script type='javascript'>alert('foo');</script>"})
    refute String.match? get_change(changeset, :body), ~r{<script>}
  end

  test "when the body includes a iframe tag" do
    changeset = Course.changeset(%Course{},
    %{@valid_attrs | body: "Hello <iframe type='javascript'>alert('foo');</iframe>"})
    refute String.match? get_change(changeset, :body), ~r{<iframe>}
  end

  test "when the body includes a link tag" do
    changeset = Course.changeset(%Course{},
    %{@valid_attrs | body: "Hello <link type='javascript'>alert('foo');</tag>"})
  refute String.match? get_change(changeset, :body), ~r{<tag>}
  end

  test "body includes no stripped tags" do
    changeset = Course.changeset(%Course{}, @valid_attrs)
    assert get_change(changeset, :body) == @valid_attrs.body
  end
end
