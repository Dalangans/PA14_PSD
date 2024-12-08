# PA14_PSD

### Run only one time

**BACKGROUND**

Pada projek kali ini, kami tentunya sudah belajar tentang penggunaan VHDL. Projek kami membuat suatu image compression yang menggunakan file format BMP. Kompresi ini mempunyai tujuan agar resolusi gambar pixel yang dimasukkan ke dalam file “input.bmp” dapat berkurang dan ditujukan ke dalam file “out.bmp”.

**PROGRAM**

**1. ReadBMP**

Entitas ReadBMP ini bertugas untuk membaca “image.bmp” ini dari file yang sudah dimasukkan ke dalam folder yang sama pada project ModelSIM. 

Cara kerja ReadBMP ini mengecek lebar gambar dan tingginya terlebih dahulu (referensi dari contoh colouring pad).

**2. WriteBMP**

Entitas WriteBMP ini bertugas untuk otomatis membuat file “out.bmp” ini dari file yang sudah dikompresi dan dimasukkan ke file “out.bmp” ini.

Cara kerja WriteBMP ini hanya menginput file yang sudah jadi dan menggunakan colouring pad pada red, blue, dan green.

**3. ImageCompression**

Entitas ImageCompression ini bertugas untuk melakukan kompresi file dari file “input.bmp”.

Cara kerja ImageCompression ini awalnya meng-adjust dahulu apakah pixel ini genap atau ganjil. Setelah itu, akan meng-update header kompres dan melakukan update ukuran headernya. 

**4. Array_pkg**

Entitas Array_pkg ini berupa header array yang membuat suatu tipe data red, green, dan blue untuk dijadikan 8 bit.

Cara kerja Array_pkg ini berupa header dari semua entitas sebelumnya yang dapat dipakai untuk tipe data yang saling berhubungan.

**5. TopLevel**

TopLevel ini berfungsi untuk menggabungkan entitas yang sebelumnya, entity ini berfungsi untuk test run pada modelSIM dengan memberikan current state (Idle, Reading, Compress, Done).

TopLevel ini menggunakan clock, start (memulai read,compres, dll), serta status. Saat sudah dikompress, statusnya akan berubah menjadi 1 yang menandakan sudah di write pada file “out.bmp”


**PROJECT DESCRIPTION**

Proyek Image Compression ini bertujuan untuk mengurangi resolusi gambar BMP menggunakan algoritma Mean Filtering. Proyek ini melibatkan tiga tahap utama, yaitu:

**a. Decode:** Membaca gambar BMP dan mengkonversinya menjadi format data yang dapat diproses.

**b. Execute:** Menerapkan algoritma Mean Filtering pada gambar untuk mengurangi resolusinya sesuai dengan preset yang dipilih.

**c. Write:** Menyimpan gambar yang telah diproses ke dalam format BMP dengan resolusi yang lebih rendah.


**TESTING & RESULT**

![8TCQe.jpg](https://s6.imgcdn.dev/8TCQe.jpg)

Pengujian dilakukan untuk memastikan bahwa entitas TopLevel dapat menjalankan semua langkah kerja yang meliputi membaca file gambar BMP, proses kompresi, dan menulis gambar yang telah dikompresi ke file BMP baru.  Hasilnya, sinyal internal dan output dipantau untuk memastikan bahwa FSM (Finite State Machine) beroperasi sesuai dengan alur yang direncanakan.

Pada tahap awal, sistem berada dalam keadaan Idle menunggu sinyal start diaktifkan. Ketika sinyal start dinaikkan ke 1, FSM berpindah ke state Reading, di mana modul ReadBMP membaca file BMP untuk mengambil header, lebar, dan tinggi gambar.Setelah data gambar berhasil dibaca, FSM melanjutkan ke state Compress, di mana proses kompresi dilakukan oleh modul ImageCompressor berdasarkan ukuran blok yang ditentukan oleh op code. Ukuran blok pada pengujian ini adalah 2x2 sesuai dengan nilai op_code "0010". Setelah kompresi selesai, FSM berpindah ke state Writing, dimana modul WriteBMP menulis gambar hasil kompresi ke file output. Setelah proses penulisan selesai, FSM masuk ke state Done.

![8TUin.jpg](https://s6.imgcdn.dev/8TUin.jpg)

![8TPEO.jpg](https://s6.imgcdn.dev/8TPEO.jpg)

![8TKOo.jpg](https://s6.imgcdn.dev/8TKOo.jpg)


**REFERENCES**

- J. J. Jensen, “BMP file bitmap image read using TEXTIO,” VHDLwhiz, Nov. 13, 2019. https://vhdlwhiz.com/read-bmp-file/

- R. Fisher, S. Perkins, A. Walker, and E. Wolfart, “Spatial Filters - Mean Filter,” homepages.inf.ed.ac.uk, 2003. https://homepages.inf.ed.ac.uk/rbf/HIPR2/mean.htm

- Modul di Emas

- Russell, “Arrays - VHDL Example. Learn to create 2D synthesizable arrays,” Nandland, Jun. 09, 2022. https://nandland.com/arrays/