// ignore_for_file: non_constant_identifier_names

import 'package:equatable/equatable.dart';

class Gasto with EquatableMixin{
  int? gastoId;
  final String descripcion;
  final String lugar;
  final double cantidad;
  final String fecha;
  final int categoria_id;
  final int vehiculo_id;

  
  
  factory Gasto.fromMap(Map<String, dynamic> map){
    return Gasto(
      gastoId: map['id'],
      descripcion: map['descripcion'],
      lugar: map['lugar'],
      cantidad: map['cantidad'],
      fecha: map['fecha'],
      vehiculo_id: map['vehiculo_id'],
      categoria_id: map['categoria_id'],

    );
  }

  Gasto({this.gastoId,required this.descripcion, required this.lugar, required this.cantidad, required this.fecha, required this.categoria_id, required this.vehiculo_id});




  @override
  List<Object?> get props => [gastoId,descripcion, lugar, cantidad, fecha, vehiculo_id, categoria_id];

} 
