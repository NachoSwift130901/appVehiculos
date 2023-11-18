import 'package:equatable/equatable.dart';

class Gasto with EquatableMixin{
  final String descripcion;
  final String lugar;
  final double cantidad;
  final DateTime fecha;
  final String vehiculoId;
  final String categoria;

  Gasto(this.vehiculoId, this.categoria, {required this.descripcion, required this.lugar, required this.cantidad, required this.fecha});
  
  @override
  List<Object?> get props => [descripcion, lugar, cantidad, fecha, vehiculoId, categoria];

} 
