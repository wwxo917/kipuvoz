/// Datos de ejemplo que siguen en la app hasta los sprints 3 y 4:
/// la pantalla de Confirmación (la IA llega en el Sprint 4).
class ConfirmItem {
  const ConfirmItem({required this.product, required this.quantity, required this.unit, required this.price});

  final String product;
  final int quantity;
  final String unit;
  final double price; // precio unitario

  double get subtotal => quantity * price;
}

const sampleConfirmItems = <ConfirmItem>[
  ConfirmItem(product: 'Arroz', quantity: 5, unit: 'bolsas', price: 40),
  ConfirmItem(product: 'Aceite', quantity: 2, unit: 'unid.', price: 18),
];
