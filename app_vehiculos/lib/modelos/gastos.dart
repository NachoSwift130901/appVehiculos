import 'package:equatable/equatable.dart';

class Gastos with EquatableMixin{
  final String descripcion;
  final String lugar;
  final String cantidad;
  final String fecha;

  Gastos({required this.descripcion, required this.lugar, required this.cantidad, required this.fecha});
  
  @override
  List<Object?> get props => [descripcion, lugar, cantidad, fecha];

} 
