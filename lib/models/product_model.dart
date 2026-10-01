class Product {
  final String? id;
  final String name;
  final double price;
  final String? imageUrl;
  final String? description;
  final int? stock;
  final String? category;
  final String? status;

  Product({
    this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    this.description,
    this.stock,
    this.category,
    this.status,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    double parsedPrice = 0.0;
    if (json['price'] != null) {
      if (json['price'] is num) {
        parsedPrice = (json['price'] as num).toDouble();
      } else if (json['price'] is String) {
        parsedPrice = double.tryParse(json['price'].toString()) ?? 0.0;
      }
    }

    int? parsedStock;
    if (json['stock'] != null) {
      if (json['stock'] is int) {
        parsedStock = json['stock'] as int;
      } else if (json['stock'] is String) {
        parsedStock = int.tryParse(json['stock'].toString());
      }
    }

    return Product(
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? 'Tanpa Nama',
      price: parsedPrice,
      imageUrl: json['image_url']?.toString(),
      description: json['description']?.toString(),
      stock: parsedStock,
      category: json['category']?.toString(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'price': price,
    };

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      data['image_url'] = imageUrl;
    }
    if (description != null) {
      data['description'] = description;
    }
    if (stock != null) {
      data['stock'] = stock;
    }
    if (category != null) {
      data['category'] = category;
    }
    if (status != null) {
      data['status'] = status;
    }

    return data;
  }

  String get formattedPrice {
    final priceInt = price.toInt();
    final buffer = StringBuffer();
    final priceStr = priceInt.toString();
    int count = 0;

    for (int i = priceStr.length - 1; i >= 0; i--) {
      buffer.write(priceStr[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }

    final reversed = buffer.toString().split('').reversed.join('');
    return 'Rp $reversed';
  }
}
