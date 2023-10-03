defmodule AsyncTestWeb.InnerLive do
  alias Phoenix.LiveView.AsyncResult
  use AsyncTestWeb, :live_view

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <%= if connected?(@socket) do %>
      <.async_result :let={text} assign={@text}>
        <:loading>&gt; Loading inner live view...</:loading>

        <:failed>&gt; Failed to load inner live text</:failed>

        <h1>
          <%= text %>
        </h1>
      </.async_result>

      <%= live_render(
        @socket,
        AsyncTestWeb.SecondaryLive,
        id: :secondary,
        params: @params
      ) %>
    <% else %>
      <p>Connecting inner...</p>
    <% end %>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    send(socket.parent_pid, {:subscribe, self()})
    socket = assign(socket, text: AsyncResult.loading(), params: %{})

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_info({:parent_params, params}, socket) do
    socket =
      socket
      |> assign(:params, params)
      |> assign_async([:text], fn ->
        Process.sleep(200)

        {:ok, %{text: "> Inner received params"}}
      end)

    {:noreply, socket}
  end

  def handle_info({:listening, _pid}, socket) do
    socket =
      socket
      |> assign_async([:text], fn ->
        {:ok, %{text: "> Inner attached to parent"}}
      end)

    {:noreply, socket}
  end

  def handle_info({:subscribe, pid}, socket) do
    Process.monitor(pid)
    subscriptions = Map.get(socket.assigns, :subscriptions, [])
    subscriptions = [pid | subscriptions]

    send(pid, {:listening, self()})

    {:noreply, assign(socket, subscriptions: subscriptions)}
  end
end
