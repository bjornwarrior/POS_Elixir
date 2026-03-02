defmodule SimpleErp.CatalogTest do
  use SimpleErp.DataCase

  alias SimpleErp.Catalog
  alias SimpleErp.Catalog.Product
  alias SimpleErp.Kategori.Category # Pastikan alias ini ada

  setup do
    {:ok, category} = Repo.insert(%Category{name: "Umum"})
    # Menyiapkan data awal untuk setiap test
    {:ok, product} =
      Repo.insert(%Product{
        name: "Kopi",
        price: 5000,
        stock: 10,
        # <--- Pakai ID asli hasil insert
        category_id: category.id
      })

    %{product: product}
  end

  test "jual_produk/2 berhasil mengurangi stok dan mencatat sales", %{product: p} do
    assert {:ok, result} = Catalog.jual_produk(p.id, 2)

    # Cek apakah stok berkurang jadi 8
    assert result.update_stok.stock == 8

    # Cek apakah record sales tercipta dengan total harga yang benar (5000 * 2 = 10000)
    assert result.catat_sale.qty == 2
    assert Decimal.equal?(result.catat_sale.total_price, 10000)
  end

  test "jual_produk/2 gagal jika stok tidak mencukupi", %{product: p} do
    # Coba jual 11 padahal stok cuma 10
    assert {:error, :update_stok, changeset, _} = Catalog.jual_produk(p.id, 11)

    # Pastikan ada pesan error di changeset
    assert "Stok gudang tidak bisa negatif!" in errors_on(changeset).stock
  end

  # describe "products" do
  #   alias SimpleErp.Catalog.Product

  #   import SimpleErp.CatalogFixtures

  #   @invalid_attrs %{name: nil, stock: nil}

  #   test "list_products/0 returns all products" do
  #     product = product_fixture()
  #     assert Catalog.list_products() == [product]
  #   end

  #   test "get_product!/1 returns the product with given id" do
  #     product = product_fixture()
  #     assert Catalog.get_product!(product.id) == product
  #   end

  #   test "create_product/1 with valid data creates a product" do
  #     valid_attrs = %{name: "some name", stock: 42}

  #     assert {:ok, %Product{} = product} = Catalog.create_product(valid_attrs)
  #     assert product.name == "some name"
  #     assert product.stock == 42
  #   end

  #   test "create_product/1 with invalid data returns error changeset" do
  #     assert {:error, %Ecto.Changeset{}} = Catalog.create_product(@invalid_attrs)
  #   end

  #   test "update_product/2 with valid data updates the product" do
  #     product = product_fixture()
  #     update_attrs = %{name: "some updated name", stock: 43}

  #     assert {:ok, %Product{} = product} = Catalog.update_product(product, update_attrs)
  #     assert product.name == "some updated name"
  #     assert product.stock == 43
  #   end

  #   test "update_product/2 with invalid data returns error changeset" do
  #     product = product_fixture()
  #     assert {:error, %Ecto.Changeset{}} = Catalog.update_product(product, @invalid_attrs)
  #     assert product == Catalog.get_product!(product.id)
  #   end

  #   test "delete_product/1 deletes the product" do
  #     product = product_fixture()
  #     assert {:ok, %Product{}} = Catalog.delete_product(product)
  #     assert_raise Ecto.NoResultsError, fn -> Catalog.get_product!(product.id) end
  #   end

  #   test "change_product/1 returns a product changeset" do
  #     product = product_fixture()
  #     assert %Ecto.Changeset{} = Catalog.change_product(product)
  #   end
  # end
end
