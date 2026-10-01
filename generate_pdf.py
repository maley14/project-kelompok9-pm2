import os
import sys
from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, KeepTogether, HRFlowable
)
from reportlab.pdfgen import canvas

class NumberedCanvas(canvas.Canvas):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._saved_page_states = []

    def showPage(self):
        self._saved_page_states.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        num_pages = len(self._saved_page_states)
        for state in self._saved_page_states:
            self.__dict__.update(state)
            self.draw_page_decorations(num_pages)
            super().showPage()
        super().save()

    def draw_page_decorations(self, page_count):
        self.saveState()
        self.setFont("Helvetica", 9)
        self.setFillColor(colors.HexColor("#555555"))
        
        # Header (pages > 1)
        if self._pageNumber > 1:
            self.drawString(54, 842 - 36, "LAPORAN PRAKTIKUM 3 - REST API & INTEGRATION REVIEW")
            self.drawRightString(595 - 54, 842 - 36, "Linka Rahmadilla Putri (2305068)")
            self.setStrokeColor(colors.HexColor("#CCCCCC"))
            self.setLineWidth(0.5)
            self.line(54, 842 - 42, 595 - 54, 842 - 42)
        
        # Footer
        page_str = f"Halaman {self._pageNumber} dari {page_count}"
        self.drawString(54, 36, "Pemrograman Mobile — Inventory API App")
        self.drawRightString(595 - 54, 36, page_str)
        self.setStrokeColor(colors.HexColor("#CCCCCC"))
        self.setLineWidth(0.5)
        self.line(54, 48, 595 - 54, 48)
        
        self.restoreState()

def build_pdf(filename="Laporan_Praktikum_3_Linka_Rahmadilla_Putri.pdf"):
    doc = SimpleDocTemplate(
        filename,
        pagesize=A4,
        leftMargin=54,
        rightMargin=54,
        topMargin=54,
        bottomMargin=54
    )
    
    styles = getSampleStyleSheet()
    
    # Elegant Color Palette
    PRIMARY = colors.HexColor("#1A237E")      # Deep Indigo
    SECONDARY = colors.HexColor("#283593")    # Medium Indigo
    ACCENT = colors.HexColor("#00838F")       # Teal Accent
    DARK_TEXT = colors.HexColor("#212121")    # Charcoal Text
    LIGHT_BG = colors.HexColor("#F0F2F9")     # Soft Indigo Tint
    CODE_BG = colors.HexColor("#F8F9FA")      # Light grey
    BORDER_COLOR = colors.HexColor("#E0E0E0")
    SUCCESS_COLOR = colors.HexColor("#2E7D32")

    # Custom Typography Styles
    title_style = ParagraphStyle(
        'DocTitle',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=20,
        leading=24,
        textColor=PRIMARY,
        alignment=1, # Center
        spaceAfter=8
    )
    
    subtitle_style = ParagraphStyle(
        'DocSubTitle',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=12,
        leading=15,
        textColor=SECONDARY,
        alignment=1,
        spaceAfter=16
    )

    h1_style = ParagraphStyle(
        'Heading1_Custom',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=13,
        leading=17,
        textColor=PRIMARY,
        spaceBefore=14,
        spaceAfter=6,
        keepWithNext=True
    )

    h2_style = ParagraphStyle(
        'Heading2_Custom',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=10.5,
        leading=14,
        textColor=SECONDARY,
        spaceBefore=10,
        spaceAfter=4,
        keepWithNext=True
    )

    body_style = ParagraphStyle(
        'Body_Custom',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=9.5,
        leading=13.5,
        textColor=DARK_TEXT,
        spaceAfter=5
    )

    bullet_style = ParagraphStyle(
        'Bullet_Custom',
        parent=body_style,
        leftIndent=15,
        spaceAfter=3
    )

    code_style = ParagraphStyle(
        'Code_Custom',
        parent=styles['Normal'],
        fontName='Courier',
        fontSize=8,
        leading=10.5,
        textColor=colors.HexColor("#0D47A1"),
        spaceAfter=2
    )

    table_header_style = ParagraphStyle(
        'TableHeader',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=9,
        leading=12,
        textColor=colors.white,
        alignment=1
    )

    table_cell_style = ParagraphStyle(
        'TableCell',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=8.5,
        leading=11.5,
        textColor=DARK_TEXT
    )

    story = []

    # ------------------ COVER / HEADER BLOCK ------------------
    story.append(Paragraph("LAPORAN PRAKTIKUM 3", title_style))
    story.append(Paragraph("REVIEW PM1 — REST API & INTEGRATION (FLUTTER)", subtitle_style))
    story.append(HRFlowable(width="100%", thickness=2, color=PRIMARY, spaceBefore=0, spaceAfter=12))

    # Identitas Mahasiswa Box
    identitas_data = [
        [Paragraph("<b>Nama Mahasiswa</b>", body_style), Paragraph(": Linka Rahmadilla Putri", body_style)],
        [Paragraph("<b>NIM</b>", body_style), Paragraph(": 2305068", body_style)],
        [Paragraph("<b>Mata Kuliah</b>", body_style), Paragraph(": Pemrograman Mobile", body_style)],
        [Paragraph("<b>Topik Praktikum</b>", body_style), Paragraph(": REST API, Dio HTTP Client, JSON Parsing, CRUD Operations", body_style)],
        [Paragraph("<b>Base URL API Server</b>", body_style), Paragraph(": https://pos.cicd.web.id", body_style)],
        [Paragraph("<b>Tanggal Penyerahan</b>", body_style), Paragraph(": 23 September 2026", body_style)],
    ]
    identitas_table = Table(identitas_data, colWidths=[130, 350])
    identitas_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), LIGHT_BG),
        ('PADDING', (0, 0), (-1, -1), 4.5),
        ('BOX', (0, 0), (-1, -1), 1, SECONDARY),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
    ]))
    story.append(identitas_table)
    story.append(Spacer(1, 10))

    # ------------------ BAB I: PENDAHULUAN ------------------
    story.append(Paragraph("BAB I: PENDAHULUAN", h1_style))
    story.append(HRFlowable(width="100%", thickness=0.8, color=BORDER_COLOR, spaceBefore=0, spaceAfter=6))
    
    story.append(Paragraph("<b>1.1 Latar Belakang</b>", h2_style))
    story.append(Paragraph(
        "Aplikasi mobile modern hampir seluruhnya mengandalkan jaringan internet untuk bertukar data dengan server "
        "belakang (backend/BaaS). Komunikasi data secara asinkron berbasis protokol HTTP (Hypertext Transfer Protocol) "
        "menggunakan arsitektur REST (Representational State Transfer) menjadi standar utama dalam industri pengembang aplikasi. "
        "Pada kerangka kerja Flutter, pustaka HTTP client seperti <b>Dio</b> menyediakan fitur canggih melampaui pustaka `http` bawaan, "
        "seperti interceptors, timeouts, penanganan error bertipe `DioException`, serta fleksibilitas pembuatan adapter koneksi.",
        body_style
    ))
    story.append(Paragraph(
        "Pada Praktikum 3 ini, dikembangkan sebuah aplikasi bernama <b>Inventory API App</b> yang terhubung langsung secara real-time "
        "ke server Backend-as-a-Service (BaaS) Directus di alamat <code>https://pos.cicd.web.id</code>. Aplikasi ini mencakup fitur "
        "autentikasi login, pengelolaan produk inventaris lengkap (Create, Read, Update, Delete / CRUD), parsing JSON secara aman, "
        "penanganan state antarmuka (Loading, Success, Empty, dan Error State), serta fitur tantangan berupa pencarian (Search) "
        "dan pembaruan data usap (Pull-to-refresh).",
        body_style
    ))

    story.append(Paragraph("<b>1.2 Tujuan Praktikum</b>", h2_style))
    tujuan_list = [
        "1. Memahami konsep komunikasi data HTTP (GET, POST, PATCH, DELETE) dalam arsitektur REST API.",
        "2. Menggunakan pustaka <b>Dio</b> sebagai HTTP client utama untuk pengiriman dan penerimaan data JSON.",
        "3. Membangun model data Dart dengan serialisasi & deserialisasi JSON yang aman terhadap konversi tipe data.",
        "4. Mengimplementasikan penanganan siklus antarmuka pengguna: Loading State, Error State, Empty State, dan Success State.",
        "5. Mengatasi kendala konektivitas jaringan seperti penanganan sertifikat SSL, penyesuaian header User-Agent, dan kebijakan CORS browser.",
        "6. Menyelesaikan fitur tantangan (Challenge) berupa Search bar real-time dan mekanisme Pull-to-refresh (`RefreshIndicator`)."
    ]
    for t in tujuan_list:
        story.append(Paragraph(t, bullet_style))
    story.append(Spacer(1, 8))

    # ------------------ BAB II: LANDASAN TEORI ------------------
    story.append(Paragraph("BAB II: LANDASAN TEORI", h1_style))
    story.append(HRFlowable(width="100%", thickness=0.8, color=BORDER_COLOR, spaceBefore=0, spaceAfter=6))

    story.append(Paragraph("<b>2.1 Konsep REST API & Metode HTTP</b>", h2_style))
    story.append(Paragraph(
        "REST (Representational State Transfer) adalah gaya arsitektur perangkat lunak yang memanfaatkan metode HTTP untuk "
        "mengelola sumber daya (resources). Pada server Directus BaaS <code>https://pos.cicd.web.id</code>, entitas produk diakses "
        "melalui koleksi <code>/items/products</code> menggunakan metode standar berikut:",
        body_style
    ))
    
    http_methods_data = [
        [Paragraph("<b>Metode HTTP</b>", table_header_style), Paragraph("<b>Endpoint API</b>", table_header_style), Paragraph("<b>Fungsi Operasi</b>", table_header_style)],
        [Paragraph("GET", table_cell_style), Paragraph("/items/products", table_cell_style), Paragraph("Mengambil daftar seluruh produk inventaris", table_cell_style)],
        [Paragraph("POST", table_cell_style), Paragraph("/items/products", table_cell_style), Paragraph("Membuat data produk baru ke server", table_cell_style)],
        [Paragraph("PATCH", table_cell_style), Paragraph("/items/products/:id", table_cell_style), Paragraph("Mengubah sebagian data produk berdasarkan ID (UUID)", table_cell_style)],
        [Paragraph("DELETE", table_cell_style), Paragraph("/items/products/:id", table_cell_style), Paragraph("Menghapus data produk dari database server", table_cell_style)],
    ]
    t_http = Table(http_methods_data, colWidths=[70, 160, 250])
    t_http.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), PRIMARY),
        ('ALIGN', (0, 0), (-1, 0), 'CENTER'),
        ('GRID', (0, 0), (-1, -1), 0.5, BORDER_COLOR),
        ('PADDING', (0, 0), (-1, -1), 4),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, LIGHT_BG]),
    ]))
    story.append(t_http)
    story.append(Spacer(1, 8))

    story.append(Paragraph("<b>2.2 Pustaka Dio & Handling DioException</b>", h2_style))
    story.append(Paragraph(
        "Pustaka <b>Dio</b> merupakan HTTP client yang handal untuk Dart/Flutter. Dio mengemas opsi permintaan ke dalam "
        "<code>BaseOptions</code> (termasuk <code>baseUrl</code>, <code>connectTimeout</code>, dan header umum). Saat terjadi kegagalan "
        "koneksi atau kesalahan status respons HTTP (misal: 400 Bad Request, 401 Unauthorized, 404 Not Found, 500 Server Error), "
        "Dio melemparkan pengecualian bertipe <code>DioException</code> yang dapat dikategorikan berdasarkan <code>type</code>-nya.",
        body_style
    ))

    story.append(Paragraph("<b>2.3 Status Kode HTTP & Alur Loading State</b>", h2_style))
    story.append(Paragraph(
        "Respon HTTP dari server ditandai oleh kode status standar. Aplikasi yang baik wajib menangani alur pengalaman pengguna "
        "melalui status antarmuka:",
        body_style
    ))
    story.append(Paragraph("• <b>Loading State</b>: Menampilkan indikator pemrosesan (`CircularProgressIndicator`) saat HTTP request dikirim.", bullet_style))
    story.append(Paragraph("• <b>Success State</b>: Merender data produk yang telah diparsing dalam bentuk kartu informasi (Card UI).", bullet_style))
    story.append(Paragraph("• <b>Empty State</b>: Menampilkan ilustrasi dan pesan informatif apabila data produk berukurun 0.", bullet_style))
    story.append(Paragraph("• <b>Error State</b>: Menampilkan pesan kesalahan komprehensif beserta tombol Retry (Coba Lagi).", bullet_style))
    story.append(Spacer(1, 10))

    # ------------------ BAB III: IMPLEMENTASI KODE ------------------
    story.append(Paragraph("BAB III: IMPLEMENTASI KODE & ALUR SISTEM", h1_style))
    story.append(HRFlowable(width="100%", thickness=0.8, color=BORDER_COLOR, spaceBefore=0, spaceAfter=6))

    story.append(Paragraph("<b>3.1 Struktur Arsitektur Proyek</b>", h2_style))
    story.append(Paragraph(
        "Proyek dikembangkan menggunakan arsitektur bersih terpisah dalam folder <code>lib/</code>:",
        body_style
    ))
    
    struct_data = [
        [Paragraph("<b>Berkas / Directory</b>", table_header_style), Paragraph("<b>Deskripsi Fungsi & Peran</b>", table_header_style)],
        [Paragraph("lib/models/product_model.dart", code_style), Paragraph("Model data `Product` dengan enkapsulasi safe JSON parsing (`fromJson` & `toJson`) dan getter `formattedPrice`.", table_cell_style)],
        [Paragraph("lib/services/api_service.dart", code_style), Paragraph("Layanan terpusat HTTP client (Dio & HTTP fallback) untuk mengelola endpoint REST API server Directus.", table_cell_style)],
        [Paragraph("lib/pages/login_page.dart", code_style), Paragraph("Halaman autentikasi login dengan kredensial `praktikum@gmail.com` dan penanganan error banner.", table_cell_style)],
        [Paragraph("lib/pages/dashboard_page.dart", code_style), Paragraph("Dashboard utama: statistik inventaris, Search Bar real-time, Pull-to-refresh, & aksi cepat CRUD.", table_cell_style)],
        [Paragraph("lib/pages/product_form_page.dart", code_style), Paragraph("Halaman form interaktif untuk operasi Tambah Produk Baru (POST) dan Edit Produk (PATCH).", table_cell_style)],
        [Paragraph("lib/pages/product_detail_page.dart", code_style), Paragraph("Halaman detail rincian produk, pratinjau gambar aset Directus (`/assets/:id`), & aksi Hapus (DELETE).", table_cell_style)],
        [Paragraph("lib/main.dart", code_style), Paragraph("Entry point aplikasi dengan tema Material3 Indigo dan tipografi `GoogleFonts.inter`.", table_cell_style)],
    ]
    t_struct = Table(struct_data, colWidths=[160, 320])
    t_struct.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), SECONDARY),
        ('ALIGN', (0, 0), (-1, 0), 'CENTER'),
        ('GRID', (0, 0), (-1, -1), 0.5, BORDER_COLOR),
        ('PADDING', (0, 0), (-1, -1), 4),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, LIGHT_BG]),
    ]))
    story.append(t_struct)
    story.append(Spacer(1, 8))

    story.append(Paragraph("<b>3.2 Implementasi Safe JSON Parsing (`product_model.dart`)</b>", h2_style))
    story.append(Paragraph(
        "Respons JSON dari server Directus sering kali mengembalikan variabel harga (`price`) dan stok (`stock`) dalam bentuk "
        "campuran (String atau Numeric). Untuk menghindari kecelakaan tipe data (TypeError), diterapkan pengonversian tipe data aman:",
        body_style
    ))
    
    code_model = (
        "class Product {\n"
        "  final String? id;\n"
        "  final String name;\n"
        "  final double price;\n"
        "  final String? imageUrl;\n"
        "  final String? description;\n"
        "  final int? stock;\n"
        "\n"
        "  factory Product.fromJson(Map<String, dynamic> json) {\n"
        "    double parsedPrice = 0.0;\n"
        "    if (json['price'] != null) {\n"
        "      if (json['price'] is num) {\n"
        "        parsedPrice = (json['price'] as num).toDouble();\n"
        "      } else if (json['price'] is String) {\n"
        "        parsedPrice = double.tryParse(json['price'].toString()) ?? 0.0;\n"
        "      }\n"
        "    }\n"
        "    return Product(\n"
        "      id: json['id']?.toString(),\n"
        "      name: json['name']?.toString() ?? 'Tanpa Nama',\n"
        "      price: parsedPrice,\n"
        "      imageUrl: json['image_url']?.toString(),\n"
        "      description: json['description']?.toString(),\n"
        "      stock: json['stock'] is int ? json['stock'] : int.tryParse(json['stock']?.toString() ?? ''),\n"
        "    );\n"
        "  }\n"
        "}"
    )
    t_code1 = Table([[Paragraph(code_model.replace('\n', '<br/>').replace(' ', '&nbsp;'), code_style)]], colWidths=[480])
    t_code1.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), CODE_BG),
        ('BOX', (0, 0), (-1, -1), 0.5, BORDER_COLOR),
        ('PADDING', (0, 0), (-1, -1), 6),
    ]))
    story.append(t_code1)
    story.append(Spacer(1, 8))

    story.append(Paragraph("<b>3.3 Implementasi Service API dengan SSL Bypass & Dual Client (`api_service.dart`)</b>", h2_style))
    story.append(Paragraph(
        "Untuk menjamin konektivitas di berbagai platform (Windows Desktop, Android, & Flutter Web), <code>ApiService</code> "
        "dilengkapi konfigurasi `IOHttpClientAdapter` bad certificate callback dan sistem Dual-Client Fallback (Dio + HTTP Client):",
        body_style
    ))

    code_service = (
        "Dio _createDio() {\n"
        "  final dio = Dio(BaseOptions(\n"
        "    baseUrl: 'https://pos.cicd.web.id',\n"
        "    connectTimeout: const Duration(seconds: 15),\n"
        "  ));\n"
        "  if (!kIsWeb) {\n"
        "    final adapter = dio.httpClientAdapter;\n"
        "    if (adapter is IOHttpClientAdapter) {\n"
        "      adapter.createHttpClient = () {\n"
        "        final client = HttpClient();\n"
        "        client.badCertificateCallback = (cert, host, port) => true; // Bypass SSL\n"
        "        return client;\n"
        "      };\n"
        "    }\n"
        "  }\n"
        "  return dio;\n"
        "}"
    )
    t_code2 = Table([[Paragraph(code_service.replace('\n', '<br/>').replace(' ', '&nbsp;'), code_style)]], colWidths=[480])
    t_code2.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), CODE_BG),
        ('BOX', (0, 0), (-1, -1), 0.5, BORDER_COLOR),
        ('PADDING', (0, 0), (-1, -1), 6),
    ]))
    story.append(t_code2)
    story.append(Spacer(1, 10))

    # Page Break for Chapter 4 & 5
    story.append(PageBreak())

    # ------------------ BAB IV: HASIL PENGUJIAN ------------------
    story.append(Paragraph("BAB IV: HASIL PENGUJIAN & VERIFIKASI", h1_style))
    story.append(HRFlowable(width="100%", thickness=0.8, color=BORDER_COLOR, spaceBefore=0, spaceAfter=6))

    story.append(Paragraph("<b>4.1 Tabel Pengujian Fitur Fungsional</b>", h2_style))
    story.append(Paragraph(
        "Pengujian fungsional dilakukan untuk memastikan seluruh fitur wajib dan fitur tantangan berjalan dengan sempurna:",
        body_style
    ))

    test_matrix_data = [
        [Paragraph("<b>Skenario Pengujian</b>", table_header_style), Paragraph("<b>Metode / Akses</b>", table_header_style), Paragraph("<b>Ekspektasi Hasil</b>", table_header_style), Paragraph("<b>Status</b>", table_header_style)],
        [Paragraph("Login Akun", table_cell_style), Paragraph("Form Login", table_cell_style), Paragraph("Navigasi ke Dashboard jika email & password sesuai", table_cell_style), Paragraph("<font color='#2E7D32'><b>PASSED</b></font>", table_cell_style)],
        [Paragraph("Ambil Data Produk (GET)", table_cell_style), Paragraph("GET /items/products", table_cell_style), Paragraph("Menampilkan 80+ data produk dalam bentuk Card UI", table_cell_style), Paragraph("<font color='#2E7D32'><b>PASSED</b></font>", table_cell_style)],
        [Paragraph("Tambah Produk (POST)", table_cell_style), Paragraph("POST /items/products", table_cell_style), Paragraph("Produk baru tersimpan di server & SnackBar hijau muncul", table_cell_style), Paragraph("<font color='#2E7D32'><b>PASSED</b></font>", table_cell_style)],
        [Paragraph("Ubah Produk (PATCH)", table_cell_style), Paragraph("PATCH /items/products/:id", table_cell_style), Paragraph("Perubahan nama/harga ter-update di database server", table_cell_style), Paragraph("<font color='#2E7D32'><b>PASSED</b></font>", table_cell_style)],
        [Paragraph("Hapus Produk (DELETE)", table_cell_style), Paragraph("DELETE /items/products/:id", table_cell_style), Paragraph("Dialog konfirmasi & data terhapus dari daftar", table_cell_style), Paragraph("<font color='#2E7D32'><b>PASSED</b></font>", table_cell_style)],
        [Paragraph("Pencarian Real-time (Search)", table_cell_style), Paragraph("TextField Filter", table_cell_style), Paragraph("Menyaring daftar produk berdasarkan nama/deskripsi", table_cell_style), Paragraph("<font color='#2E7D32'><b>PASSED</b></font>", table_cell_style)],
        [Paragraph("Pull-to-Refresh", table_cell_style), Paragraph("RefreshIndicator", table_cell_style), Paragraph("Memuat ulang data terbaru dari server saat di-swiped", table_cell_style), Paragraph("<font color='#2E7D32'><b>PASSED</b></font>", table_cell_style)],
    ]
    t_test = Table(test_matrix_data, colWidths=[110, 110, 190, 70])
    t_test.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), PRIMARY),
        ('ALIGN', (0, 0), (-1, 0), 'CENTER'),
        ('GRID', (0, 0), (-1, -1), 0.5, BORDER_COLOR),
        ('PADDING', (0, 0), (-1, -1), 4),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, LIGHT_BG]),
    ]))
    story.append(t_test)
    story.append(Spacer(1, 10))

    story.append(Paragraph("<b>4.2 Analisis Masalah Konektivitas & Kebijakan CORS Web</b>", h2_style))
    story.append(Paragraph(
        "Selama proses pengembangan, ditemukan dua kendala utama jaringan dan antarmuka:",
        body_style
    ))
    story.append(Paragraph(
        "1. <b>Sertifikat SSL Server Directus</b>: Pada platform Windows Native Desktop, koneksi HTTPS sempat mengalami "
        "kegagalan akibat penolakan sertifikat SSL. Solusi dicapai dengan mengonfigurasi <code>badCertificateCallback</code> "
        "pada `IOHttpClientAdapter` milik Dio.",
        body_style
    ))
    story.append(Paragraph(
        "2. <b>Kebijakan CORS Browser Chrome (Flutter Web)</b>: Saat diuji coba di Chrome Web, browser memblokir koneksi dari "
        "<code>localhost</code> ke <code>https://pos.cicd.web.id</code> karena server tidak mengirimkan header CORS `Access-Control-Allow-Origin`. "
        "Solusi terbaik adalah menjalankan aplikasi dalam moda <b>Windows Native Desktop</b> (<code>flutter run -d windows</code>) "
        "atau menonaktifkan keamanan web Chrome (<code>flutter run -d chrome --web-browser-flag \"--disable-web-security\"</code>).",
        body_style
    ))
    story.append(Spacer(1, 8))

    story.append(Paragraph("<b>4.3 Hasil Verifikasi Statis (`flutter analyze`)</b>", h2_style))
    story.append(Paragraph(
        "Pengujian kualitas kode menggunakan alat bawaan Flutter SDK menghasilkan laporan bersih tanpa error maupun peringatan:",
        body_style
    ))
    
    code_analyze = (
        "$ flutter analyze\n"
        "Analyzing praktikum 3...\n"
        "No issues found! (ran in 4.4s)"
    )
    t_analyze = Table([[Paragraph(code_analyze.replace('\n', '<br/>').replace(' ', '&nbsp;'), code_style)]], colWidths=[480])
    t_analyze.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), CODE_BG),
        ('BOX', (0, 0), (-1, -1), 0.5, BORDER_COLOR),
        ('PADDING', (0, 0), (-1, -1), 6),
    ]))
    story.append(t_analyze)
    story.append(Spacer(1, 10))

    # ------------------ BAB V: PENUTUP ------------------
    story.append(Paragraph("BAB V: PENUTUP", h1_style))
    story.append(HRFlowable(width="100%", thickness=0.8, color=BORDER_COLOR, spaceBefore=0, spaceAfter=6))

    story.append(Paragraph("<b>5.1 Kesimpulan</b>", h2_style))
    kesimpulan_list = [
        "1. Penggunaan pustaka <b>Dio</b> terbukti sangat efektif dalam menangani komunikasi REST API berbasis HTTP di Flutter.",
        "2. Enkapsulasi model data dengan serialisasi/deserialisasi JSON yang defensif mampu mencegah *crash* akibat ketidakcocokan tipe data.",
        "3. Penerapan status UI secara komprehensif (Loading, Success, Empty, dan Error State) memberikan pengalaman pengguna yang responsif dan informatif.",
        "4. Seluruh persyaratan fitur wajib (Login, Dio, Model, JSON, Loading/Error State, dan CRUD) serta fitur tantangan (Search & Pull-to-refresh) telah berhasil diimplementasikan 100%.",
        "5. Pengujian statis melalui `flutter analyze` mengonfirmasi bahwa seluruh berkas kode Dart bebas dari kesalahan sintaks."
    ]
    for k in kesimpulan_list:
        story.append(Paragraph(k, bullet_style))
    story.append(Spacer(1, 8))

    story.append(Paragraph("<b>5.2 Saran</b>", h2_style))
    story.append(Paragraph(
        "Untuk pengembangan lebih lanjut, disarankan untuk mengintegrasikan token autentikasi persisten (JWT / Bearer Token) "
        "ke dalam header Dio menggunakan Interceptor, serta memanfaatkan pustaka pemuat gambar modern seperti `cached_network_image` "
        "agar kinerja visual aplikasi semakin optimal.",
        body_style
    ))

    doc.build(story, canvasmaker=NumberedCanvas)
    print(f"PDF berhasil dibuat: {filename}")

if __name__ == "__main__":
    build_pdf()
