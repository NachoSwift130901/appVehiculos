import 'package:equatable/equatable.dart';

class Gasto with EquatableMixin{
  String descripcion;
  String lugar;
  double cantidad;
  DateTime fecha;

  Gasto({required this.descripcion, required this.lugar, required this.cantidad, required this.fecha});
  
  @override
  List<Object?> get props => [descripcion, lugar, cantidad, fecha];

} 
