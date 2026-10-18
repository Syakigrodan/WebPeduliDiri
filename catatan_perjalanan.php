<div class="card">
    <div class="class-harder">
        <a href="user.php" class="btn btn-primary btn-icon-split">
            <span class="icon text-white-50">
                <i class="fa fa-arrow-left"></i>
            </span>
            <span class="text">Kembali </span>
        </a>
    </div>
    <div class="card-body">
        <div class="table-responsive">
            <table class="table table-bordered" id="dataTable" width="100%" cellspacing="0">
                <thead>
                    <tr>
                        <th>No</th>
                        <th>Tanggal</th>
                        <th>Jam</th>
                        <th>Lokasi</th>
                        <th>Suhu Tubuh</th>
                        <th>Edit</th>
                        <th>Hapus</th>
                    </tr>
                </thead>
                <tbody>
                    <?php
                    $no = 1;
                    $data = file('catatan.txt', FILE_IGNORE_NEW_LINES);
                    $user = $_SESSION['nik'] . "|" . $_SESSION['nama_lengkap'];
                    foreach ($data as $value) {
                        $pecah = explode("|", $value);
                        @$key = $pecah['1'] . "|" . $pecah['2'];
                        if ($key == $user) {
                    ?>

                            <tr>
                                <td><?= $no++; ?></td>
                                <td><?= $pecah['3']; ?></td>
                                <td><?= $pecah['4']; ?></td>
                                <td><?= $pecah['5']; ?></td>
                                <td><?= $pecah['6']; ?></td>
                                <td><a href="?url=edit_catatan&id_catatan=<?= $pecah['0'] ?>" class="btn btn-warning">
                                        <i class="fa fa-pen"></i>
                                    </a>
                                </td>
                                <td>
                                    <a onclick="return confirm('Apakah anda yakin ingin menghapus...?')" href="hapus_catatan.php?id_catatan=<?= $pecah['0'] ?>" class="btn btn-danger">
                                        <i class="fa fa-trash"></i>
                                    </a>
                                </td>
                            </tr>
                    <?php }
                    } ?>
                </tbody>
            </table>
        </div>
    </div>
</div>