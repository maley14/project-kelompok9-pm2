# MATRIKULASI — REVIEW PM1 - REST API & Integration Review

### Fokus

> **Dio/HTTP, CRUD API, Error & Loading State**
> 

### Tujuan

Mahasiswa mampu:

- Memahami komunikasi HTTP.
- Menggunakan Dio.
- Mengambil data REST API.
- Mengirim data.
- Mengubah data.
- Menghapus data.
- Parsing JSON.
- Menangani loading dan error.

# 1. REST API

Konsep:

```
Flutter App
     │
     │ HTTP
     ▼
 REST API
     │
     ▼
 Database
```

---

# 2. HTTP Method

| Method | Fungsi |
| --- | --- |
| GET | Mengambil data |
| POST | Membuat data |
| PUT | Mengubah data |
| PATCH | Mengubah sebagian data |
| DELETE | Menghapus data |

---

# 3. Dio

Tambahkan dependency:

```bash
flutter pub add dio
```

Import:

```dart
import'package:dio/dio.dart';
```

Buat client:

```dart
final dio = Dio(
  BaseOptions(
    baseUrl: 'https://example.com/api',
  ),
);
```

---

# 4. GET

```dart
final response = await dio.get('/items/products');

print(response.data);
```

---

# 5. POST

```dart
final response = await dio.post(
  '/items/products',
  data: {
    'name': 'Laptop',
    'price': 7500000,
  },
);
```

---

# 6. PUT/PATCH

```dart
await dio.patch(
  '/items/products/1',
  data: {
    'name': 'MacBook',
  },
);
```

---

# 7. DELETE

```dart
await dio.delete('/items/products/1');
```

---

# 8. Parsing JSON

Response:

```json
{
"data" :
	[
	  {
	    "id": 1,
	    "name": "Laptop",
	    "price": 7500000
	  }
	]
}
```

Convert:

```dart
final products = (response.data["data"] as List)
    .map(
      (json) => Product.fromJson(json),
    )
    .toList();
```

---

# 9. Error Handling

```dart
try {
  final response = await dio.get('/items/products');

  print(response.data);
} on DioException catch (e) {
  print(e.message);
}
```

Mahasiswa minimal memahami:

```
200 → Success
201 → Created
400 → Bad Request
401 → Unauthorized
403 → Forbidden
404 → Not Found
500 → Server Error
```

---

# 10. Loading State

Flow aplikasi:

```
User membuka halaman
       ↓
Loading
       ↓
Request API
       ↓
 ┌─────┴─────┐
 ▼           ▼
Success     Error
 ▼           ▼
Data UI    Error UI
```

Contoh:

```dart
setState(() {
  isLoading = true;
});

try {
  final response = await dio.get('/items/products');

  setState(() {
    products = (response.data as List)
        .map((json) => Product.fromJson(json))
        .toList();
  });
} catch (e) {
  setState(() {
    errorMessage = 'Gagal mengambil data';
  });
} finally {
  setState(() {
    isLoading = false;
  });
}
```

---

# Praktikum 3

Menggunakan alamat BaaS berikut ini.

https://pos.cicd.web.id

**Login:** 

email: praktikum@gmail.com

password: 12345678

Cara mengakses collections/table

GET https://pos.cicd.web.id/items/products

POST https://pos.cicd.web.id/items/products

PATCH https://pos.cicd.web.id/items/products/id-product-uuid

DELETE https://pos.cicd.web.id/items/products/id-product-uuid

Mengakses Gambar/Assets

https://pos.cicd.web.id/assets/7e82272d-9218-41ee-8733-9b6326854a39

Contoh GET data menggunakan Postman

!image.png

Contoh CREATE data menggunakan Postman

!image.png

Contoh UPDATE data menggunakan Postman

!image.png

Contoh DELETE data menggunakan Postman

!image.png

Kembangkan aplikasi menjadi:

> **Inventory API App**
> 

### Fitur

```
Login / Dummy Login
       ↓
Dashboard
       ↓
Product
       ├── GET
       ├── POST
       ├── PATCH
       └── DELETE
```

### Wajib

- Dio
- Model
- JSON
- Loading
- Error handling
- CRUD

### Challenge (optional) — Tidak wajib dikerjakan

Tambahkan:

- Search
- Pagination sederhana
- Pull-to-refresh