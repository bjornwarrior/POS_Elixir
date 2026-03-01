defmodule SimpleErp.TrafficMonitorTest do
  use ExUnit.Case, async: true
  alias SimpleErp.TrafficMonitor

  test "Incrementing and retrieving stats" do
    # Ambil angka awal
    initial = TrafficMonitor.get_stats()

    # Tambah hit
    TrafficMonitor.add_hit()

    assert TrafficMonitor.get_stats() == initial + 1
  end

  test "Process survives after error (Supervision)" do
    # Cari PID Proses saat ini
    old_pid = Process.whereis(TrafficMonitor)

    # Paksa Proses mati (Simulasi Crash)
    Process.exit(old_pid, :kill)

    # Tunggu beberapa milidetik agar Supervisor bekerja
    Process.sleep(10)

    new_pid = Process.whereis(TrafficMonitor)
    assert new_pid != old_pid
    assert Process.alive?(new_pid)
    # State kembali 0 karena kita tidak pakai db untuk monitor ini
    assert TrafficMonitor.get_stats() == 0
  end
end
