defmodule AsyncTestWeb.SecondaryLive do
  use AsyncTestWeb, :live_view

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <%= if connected?(@socket) do %>
      <%= if Map.get(assigns, :secondary_text) do %>
        <.async_result :let={secondary_text} assign={@secondary_text}>
          <:loading>&gt; Loading inner live view...</:loading>

          <:failed>&gt; Failed to load secondary_text</:failed>

          <h1>
            <%= secondary_text %>
          </h1>
        </.async_result>
      <% end %>
    <% else %>
      <p>Connecting secondary...</p>
    <% end %>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket =
      assign_async(socket, [:secondary_text], fn ->
        {:ok, %{secondary_text: "> > Secondary received params"}}
      end)

    {:ok, socket}
  end
end
