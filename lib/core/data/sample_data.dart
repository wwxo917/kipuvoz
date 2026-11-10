/// Datos de ejemplo del Sprint 1 (sin base de datos todavía).
enum MovementType { sale, purchase, expense }

extension MovementTypeLabel on MovementType {
  String get label => switch (this) {
        MovementType.sale => 'Venta',
        MovementType.purchase => 'Compra',
        MovementType.expense => 'Gasto',
      };
}

class Movement {
  const Movement({
    required this.type,
    required this.items,
    required this.day,
    required this.date,
    required this.time,
    required this.amount,
  });

  final MovementType type;
  final String items; // productos o concepto
  final String day; // HOY / AYER
  final String date; // dd/mm/aaaa
  final String time;
  final double amount; // siempre positivo
}

class Product {
  const Product({
    required this.name,
    required this.price,
    required this.stock,
    required this.level,
    this.low = false,
    this.note = '',
  });

  final String name;
  final String price;
  final String stock;
  final double level; // 0.0 a 1.0
  final bool low;
  final String note;
}

/// Ítem interpretado en la pantalla de confirmación.
class ConfirmItem {
  const ConfirmItem({required this.product, required this.quantity, required this.unit, required this.price});

  final String product;
  final int quantity;
  final String unit;
  final double price; // precio unitario

  double get subtotal => quantity * price;
}

const sampleMovements = <Movement>[
  Movement(type: MovementType.sale, items: 'Arroz, aceite', day: 'HOY', date: '09/11/2026', time: '10:42', amount: 236),
  Movement(type: MovementType.expense, items: 'Transporte', day: 'HOY', date: '09/11/2026', time: '09:15', amount: 15),
  Movement(type: MovementType.purchase, items: 'Azúcar 20 kg', day: 'HOY', date: '09/11/2026', time: '08:30', amount: 120),
  Movement(type: MovementType.sale, items: 'Fideo ×10', day: 'AYER', date: '08/11/2026', time: '18:20', amount: 60),
  Movement(type: MovementType.sale, items: 'Aceite ×3', day: 'AYER', date: '08/11/2026', time: '16:05', amount: 54),
  Movement(type: MovementType.expense, items: 'Bolsas', day: 'AYER', date: '08/11/2026', time: '11:40', amount: 10),
];

const sampleProducts = <Product>[
  Product(name: 'Arroz', price: 'Bs 40 / bolsa', stock: '12 bolsas', level: 0.8),
  Product(name: 'Azúcar', price: 'Bs 8 / kg', stock: '3 kg', level: 0.2, low: true, note: 'Stock bajo · mínimo 5 kg'),
  Product(name: 'Aceite', price: 'Bs 18 / unidad', stock: '25 un.', level: 0.7),
  Product(name: 'Fideo', price: 'Bs 6 / paquete', stock: '40 paq.', level: 0.95),
];

const sampleConfirmItems = <ConfirmItem>[
  ConfirmItem(product: 'Arroz', quantity: 5, unit: 'bolsas', price: 40),
  ConfirmItem(product: 'Aceite', quantity: 2, unit: 'unid.', price: 18),
];
