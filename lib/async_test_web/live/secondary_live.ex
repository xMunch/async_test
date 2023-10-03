defmodule AsyncTestWeb.SecondaryLive do
  alias Phoenix.LiveView.AsyncResult
  use AsyncTestWeb, :live_view

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <%= if connected?(@socket) do %>
      <.async_result :let={text} assign={@text}>
        <:loading>&gt; &gt; Loading secondary live view...</:loading>

        <:failed>&gt; &gt; Failed to load secondary live text</:failed>

        <h1><%= text %></h1>
      </.async_result>

      <%= live_render(
        @socket,
        AsyncTestWeb.ThirdLive,
        id: :third,
        params: @params
      ) %>
    <% else %>
      <p>Connecting secondary...</p>
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
        {:ok, %{text: "> > Secondary received params"}}
      end)

    socket.assigns
    |> Map.get(:subscriptions, [])
    |> Enum.each(fn pid ->
      send(pid, {:parent_params, params})
    end)

    {:noreply, socket}
  end

  def handle_info({:listening, _pid}, socket) do
    socket =
      socket
      |> assign_async([:text], fn ->
        {:ok, %{text: "> > Secondary attached to Inner"}}
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
