import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class UbicacionElegida {
  const UbicacionElegida({required this.latitud, required this.longitud, this.direccion});
  final double latitud;
  final double longitud;
  final String? direccion;
}

/// OpenStreetMap + Nominatim: una consulta de dirección SOLO al confirmar.
/// No se realiza autocompletado ni geocodificación en segundo plano.
Future<UbicacionElegida?> elegirUbicacion(BuildContext context,
    {double? latitud, double? longitud}) {
  return showDialog<UbicacionElegida>(
    context: context,
    builder: (_) => _MapaSelector(latitud: latitud, longitud: longitud),
  );
}

class _MapaSelector extends StatefulWidget {
  const _MapaSelector({this.latitud, this.longitud});
  final double? latitud;
  final double? longitud;

  @override
  State<_MapaSelector> createState() => _MapaSelectorState();
}

class _MapaSelectorState extends State<_MapaSelector> {
  LatLng? _seleccion;
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    if (widget.latitud != null && widget.longitud != null) {
      _seleccion = LatLng(widget.latitud!, widget.longitud!);
    }
  }

  Future<String?> _obtenerDireccion(LatLng punto) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
      'format': 'jsonv2',
      'lat': punto.latitude.toStringAsFixed(6),
      'lon': punto.longitude.toStringAsFixed(6),
      'zoom': '18',
      'addressdetails': '0',
    });
    try {
      // En web el navegador define su User-Agent; en Android se identifica la app.
      final headers = kIsWeb ? <String, String>{}
          : <String, String>{'User-Agent': 'KipuVoz/1.0 (com.example.kipuvoz)'};
      final result = await http.get(uri, headers: headers)
          .timeout(const Duration(seconds: 7));
      if (result.statusCode != 200) return null;
      final data = jsonDecode(result.body) as Map<String, dynamic>;
      return (data['display_name'] as String?)?.trim();
    } catch (_) {
      return null; // Se pueden guardar coordenadas aunque el servicio no responda.
    }
  }

  Future<void> _guardar() async {
    final p = _seleccion;
    if (p == null) return;
    setState(() => _cargando = true);
    final direccion = await _obtenerDireccion(p);
    if (!mounted) return;
    Navigator.of(context).pop(UbicacionElegida(
      latitud: double.parse(p.latitude.toStringAsFixed(6)),
      longitud: double.parse(p.longitude.toStringAsFixed(6)),
      direccion: direccion,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inicial = _seleccion ?? const LatLng(-16.5000, -68.1500); // La Paz
    return AlertDialog(
      title: const Text('Ubicación de mi tienda'),
      contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      content: SizedBox(
        width: 560,
        height: MediaQuery.sizeOf(context).height * 0.52,
        child: Column(
          children: [
            const Text('Mueve el mapa y toca el lugar exacto de tu negocio.'),
            const SizedBox(height: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: inicial,
                      initialZoom: 15,
                      onTap: (_, punto) => setState(() => _seleccion = punto),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.kipuvoz',
                      ),
                      if (_seleccion != null)
                        MarkerLayer(markers: [Marker(
                          point: _seleccion!, width: 45, height: 52,
                          child: Icon(Icons.location_on, size: 43, color: theme.colorScheme.primary),
                        )]),
                    ],
                  ),
                  const Positioned(
                    bottom: 4, right: 4,
                    child: ColoredBox(color: Color(0xDFFFFFFF),
                      child: Padding(padding: EdgeInsets.all(3),
                        child: Text('© OpenStreetMap contributors', style: TextStyle(fontSize: 10))),),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 6),
            Text(_seleccion == null ? 'Toca el mapa para colocar el marcador.' :
                'Lat: ${_seleccion!.latitude.toStringAsFixed(6)} · Long: ${_seleccion!.longitude.toStringAsFixed(6)}',
                style: theme.textTheme.bodySmall),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _cargando ? null : () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton.icon(
          onPressed: (_seleccion == null || _cargando) ? null : _guardar,
          icon: _cargando ? const SizedBox(width: 15, height: 15,
            child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save_outlined),
          label: const Text('Usar esta ubicación'),
        ),
      ],
    );
  }
}
