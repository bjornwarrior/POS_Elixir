defmodule SimpleErp.InventoryCacheTest do
  use SimpleErp.DataCase, async: false # async: false karena kita mainan DB shared
  alias SimpleErp.InventoryCache
  alias SimpleErp.Repo
  import Ecto.Query

  setup do
    # Buat produk dummy di database untuk bahan test
    Repo.delete_all(SimpleErp.Catalog.Product)
    Repo.delete_all(SimpleErp.Shopping.CartItem)
    product = SimpleErp.CatalogFixtures.product_fixture(%{name: "Kopi", stock: 100})
    {:ok, product: product}
  end

  test "add_to_cart updates the internal state", %{product: product} do
    InventoryCache.add_to_cart(product.id, 2)

    # Intip state di RAM
    state = :sys.get_state(InventoryCache)
    assert state[product.id] == 2
  end

  test "sync_to_db persists data to cart_items table", %{product: product} do
    # 1. Masukkan data ke RAM
    InventoryCache.add_to_cart(product.id, 5)

    # 2. Paksa jalankan handle_info(:autosave) secara manual untuk testing
    send(Process.whereis(InventoryCache), :autosave)

    # Beri jeda sangat singkat agar proses DB selesai
    Process.sleep(50)

    # 3. Cek apakah data ada di tabel cart_items
    cart_item = Repo.one(from c in "cart_items", where: c.product_id == ^product.id, select: [:qty])
    assert cart_item.qty == 5

    # 4. Pastikan state di RAM kosong kembali setelah sync
    assert :sys.get_state(InventoryCache) == %{}
  end
end
