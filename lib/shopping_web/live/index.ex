defmodule ShoppingWeb.ShoppingLive.Index do
  use ShoppingWeb, :live_view

  alias ShoppingWeb.Food

  @impl true
  def render(assigns) do
    ~H"""
      <div class="container">
        <%= if @show do %>
        <h1>Fooder</h1>
        <button phx-click="ranjang" class="btn btn-outline-warning">Cart</button>
        <hr/>
        <%= if @ada do %>
        <div class="alert alert-danger" role="alert">
          <%= @exists %> sudah ada di keranjang!
        </div>
        <% end %>
        <div class="row">
          <%= for food <- @datas do %>
          <div class="col-md-4">
            <div class="card" style="width: 18rem;">
              <img src={food.img} width="220" height="220" class="card-img-top">
              <div class="card-body">
                <h5 class="card-title"><%= food.nama %></h5>
                <p class="card-text"><%= food.desc %></p>
                <p class="card-text">Harga <b>Rp. <%= food.harga %></b></p>
                <button phx-click="add" phx-value-id={food.id} class="btn btn-primary">Add To Cart</button>
              </div>
            </div>
          </div>
          <% end %>
        </div>
        <% else %>
        <h1> Cart </h1>
        <button phx-click="back" class="btn btn-secondary">Back</button>
        <hr/>
        <%= if @bayar do %>
        <div class="alert alert-success" role="alert">
          Terima kasih sudah berbelanja di toko kami!
        </div>
        <% end %>
        <table class="table">
            <thead class="thead-dark">
              <tr>
                <th scope="col">Gambar</th>
                <th scope="col">Product</th>
                <th scope="col">Qty</th>
                <th scope="col">Harga</th>
              </tr>
            </thead>
            <tbody>
              <%= for c <- @cart do %>
              <tr>
                <td>
                  <img src={c.img} width="100" height="100" />
                </td>
                <td><%= c.nama %></td>
                <td>
                  <form>
                  <input name={"qty.#{c.id}"} phx-change="qty" value={c.qty} type="number" />
                  </form>
                </td>
                <td>Rp. <%= c.harga %></td>
              </tr>
              <% end %>
              <%= if length(@cart) > 0 do %>
              <tr>
                <td></td>
                <td></td>
                <td></td>
                <td>
                  <div>
                  <b>Total</b>: Rp <%= @total %>
                  <br/>
                  <button phx-click="bayar" class="btn ml-5 mt-3 btn-outline-success">Bayar</button>
                  </div>
                </td>
              </tr>
              <% end %>
            </tbody>
          </table>
        <% end %>
      </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    data = [
      %Food{
        id: 1,
        nama: "Cireng",
        desc: "cireng ygy",
        harga: 10000,
        qty: 1,
        img: "https://img.freepik.com/premium-photo/cireng-bumbu-rujak-traditional-food-typical-west-java_917693-431.jpg"

      },
      %Food{
        id: 2,
        nama: "Martabak",
        desc: "akh naiss drim",
        harga: 20000,
        qty: 1,
        img: "https://nibble-images.b-cdn.net/nibble/original_images/194498647_853797338880001_7056004262933511072_n.jpg"

      },
      %Food{
        id: 3,
        nama: "Ayam geprek",
        desc: "pedas",
        harga: 15000,
        qty: 1,
        img: "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxleHBsb3JlLWZlZWR8Mnx8fGVufDB8fHx8fA%3D%3D&w=1000&q=80"

      }
    ]

    {:ok, socket
              |> assign(
                datas: data,
                show: true,
                cart: [],
                ada: false,
                total: 0,
                bayar: false,
                exists: "")
    }
  end

  @impl true
  def handle_event("add", %{"id" => id} = _params, %{assigns: %{datas: data, cart: cart}} = socket) do
    inserted = data |> Enum.find(fn e -> e.id == String.to_integer(id) end)
    ada = cart |> Enum.find(fn e -> e.id == String.to_integer(id) end)

    case ada do
      nil ->
        updated_cart = [inserted | cart]
        total = updated_cart |> Enum.reduce(0, fn e, acc -> e.harga + acc end)
        {:noreply, socket |> assign(show: false, cart: updated_cart, total: total)}
      _ ->
        %{nama: nama_food} = inserted
        {:noreply, socket |> assign(ada: true, exists: nama_food)}
    end
  end

  def handle_event("qty", params, %{assigns: %{cart: cart}} = socket) do
    id_product = params |> Map.keys() |> List.last() |> String.split(".") |> List.last() |> String.to_integer()
    prod = cart |> Enum.find(fn e -> e.id == id_product end)
    index_product = cart |> Enum.find_index(fn e -> e.id == id_product end)

    key = params |> Map.keys() |> List.last()
    val = params |> Map.get(key) |> String.to_integer()

    update_prod = prod |> Map.put(:harga, prod.harga * val) |> Map.put(:qty, val)
    update_cart = cart |> List.replace_at(index_product, update_prod)
    total = update_cart |> Enum.reduce(0, fn e, acc -> e.harga + acc end)
    {:noreply, socket |> assign(cart: update_cart, total: total)}
  end

  def handle_event("bayar", _params, socket), do: {:noreply, socket |> assign(cart: [], bayar: true, total: 0)}
  def handle_event("back", _params, socket), do: {:noreply, socket |> assign(show: true, ada: false, bayar: false,
  exists: "")}
  def handle_event("ranjang", _params, socket), do: {:noreply, socket |> assign(show: false, ada: false)}

end
