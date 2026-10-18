<?php
error_reporting(0);
$nik      =$_POST['nik'];
$nama_lengkap = $_POST['nama_lengkap'];

$data = file("config.txt", FILE_IGNORE_NEW_LINES);
foreach($data as $value){
    $pecah = explode("|", $value);
    if($nik==$pecah['0']){
        $cek = true;
    }
}

if($cek) {  ?>
    <script type="text/javascript">
    alert('!! Maaf NIK yang anda gunakan sudah terdaftar.');
    window.location.assign('register.php');
    </script>
<?php }else{ 
    $format = "\n$nik|$nama_lengkap";

    $file = Fopen('config.txt', 'a');
    fwrite($file, $format);

    fclose($file);

    ?>
    <script type="text/javascript">
    alert('Pendaftaran berhasil dilakukan.');
    window.location.assign('index.php');
    </script>
    <?php

}

