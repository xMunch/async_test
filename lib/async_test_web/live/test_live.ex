defmodule AsyncTestWeb.TestLive do
  use AsyncTestWeb, :live_view

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <%= if connected?(@socket) do %>
      <div id="parent">
        <.async_result :let={parent_text} assign={@parent_text}>
          <:loading>Loading parent live view...</:loading>

          <:failed>Failed to load parent_text live text</:failed>

          <h1><%= parent_text %></h1>
        </.async_result>

        <%= live_render(
          @socket,
          AsyncTestWeb.InnerLive,
          id: :inner
        ) %>
      </div>
    <% else %>
      <p>Connecting...</p>
    <% end %>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    if connected?(socket) do
      socket =
        assign_async(socket, [:parent_text], fn ->
          {:ok, %{parent_text: "Parent"}}
        end)

      {:ok, socket}
    else
      {:ok, socket}
    end
  end
end
