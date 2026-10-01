import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ApiService {
  static const String baseUrl = 'https://pos.cicd.web.id';

  Dio _createDio() {
    final Map<String, dynamic> headers = {};
    
    // Jangan set User-Agent jika di Web (Browser melarang custom User-Agent)
    if (!kIsWeb) {
      headers['Content-Type'] = 'application/json';
      headers['Accept'] = 'application/json, text/plain, */*';
      headers['User-Agent'] =
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
    }

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: headers.isNotEmpty ? headers : null,
      ),
    );

    if (!kIsWeb) {
      final adapter = dio.httpClientAdapter;
      if (adapter is IOHttpClientAdapter) {
        adapter.createHttpClient = () {
          final client = HttpClient();
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
          return client;
        };
      }
    }

    return dio;
  }

  // Authentikasi (Dummy / Check credentials)
  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (email.trim() == 'praktikum@gmail.com' && password == '12345678') {
      return true;
    } else {
      throw Exception('Email atau password tidak sesuai.');
    }
  }

  // GET: Ambil daftar produk
  Future<List<Product>> getProducts({String? search}) async {
    // 1. Request via Dio
    try {
      final dio = _createDio();
      final response = await dio.get('/items/products');
      if (response.data != null && response.data['data'] != null) {
        return _parseAndFilter(response.data['data'] as List, search);
      }
    } catch (_) {
      // Abaikan dan coba HTTP Direct
    }

    // 2. Request via Standard HTTP
    try {
      final uri = Uri.parse('$baseUrl/items/products');
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['data'] != null) {
          return _parseAndFilter(body['data'] as List, search);
        }
      }
    } catch (_) {
      // Abaikan
    }

    // Jika di lingkungan Browser (Flutter Web) dan diblokir oleh CORS Policy
    if (kIsWeb) {
      throw Exception(
        'Browser Chrome memblokir koneksi dari localhost (CORS Policy).\n\n'
        'Solusi:\n'
        '1. Jalankan di Windows (Desktop): flutter run -d windows\n'
        '2. Atau jalankan Chrome tanpa CORS: flutter run -d chrome --web-browser-flag "--disable-web-security"',
      );
    }

    throw Exception('Gagal mengambil data dari $baseUrl/items/products. Periksa koneksi internet Anda.');
  }

  // Helper Parse & Search Filter
  List<Product> _parseAndFilter(List list, String? search) {
    List<Product> products = list.map((json) => Product.fromJson(json)).toList();

    if (search != null && search.trim().isNotEmpty) {
      final query = search.trim().toLowerCase();
      products = products.where((p) {
        final nameMatch = p.name.toLowerCase().contains(query);
        final descMatch = p.description?.toLowerCase().contains(query) ?? false;
        return nameMatch || descMatch;
      }).toList();
    }

    return products;
  }

  // POST: Tambah produk baru
  Future<Product> createProduct(Product product) async {
    try {
      final dio = _createDio();
      final response = await dio.post(
        '/items/products',
        data: product.toJson(),
      );

      if (response.data != null && response.data['data'] != null) {
        return Product.fromJson(response.data['data']);
      } else {
        throw Exception('Respon dari server kosong.');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      final uri = Uri.parse('$baseUrl/items/products');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product.toJson()),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        return Product.fromJson(body['data']);
      }
      throw Exception('Gagal membuat produk: $e');
    }
  }

  // PATCH: Ubah data produk
  Future<Product> updateProduct(String id, Map<String, dynamic> data) async {
    try {
      final dio = _createDio();
      final response = await dio.patch(
        '/items/products/$id',
        data: data,
      );

      if (response.data != null && response.data['data'] != null) {
        return Product.fromJson(response.data['data']);
      } else {
        throw Exception('Gagal memperbarui data.');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      final uri = Uri.parse('$baseUrl/items/products/$id');
      final response = await http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return Product.fromJson(body['data']);
      }
      throw Exception('Gagal memperbarui produk: $e');
    }
  }

  // DELETE: Hapus produk
  Future<bool> deleteProduct(String id) async {
    try {
      final dio = _createDio();
      await dio.delete('/items/products/$id');
      return true;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      final uri = Uri.parse('$baseUrl/items/products/$id');
      final response = await http.delete(uri);
      return response.statusCode == 200 || response.statusCode == 204;
    }
  }

  // Helper mendapatkan URL aset gambar
  static String? getImageUrl(String? imageId) {
    if (imageId == null || imageId.trim().isEmpty) return null;
    return '$baseUrl/assets/$imageId';
  }

  // Formatting Error Handling Dio
  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi timeout (15s).';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        return 'Server HTTP $statusCode.';
      case DioExceptionType.cancel:
        return 'Permintaan dibatalkan.';
      case DioExceptionType.connectionError:
        return 'Connection Error (${error.message ?? error.error})';
      default:
        return 'Error (${error.message ?? error.error})';
    }
  }
}
