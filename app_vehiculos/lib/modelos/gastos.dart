// ignore_for_file: non_constant_identifier_names

import 'package:equatable/equatable.dart';

class Gasto with EquatableMixin{
  final String descripcion;
  final String lugar;
  final double cantidad;
  final DateTime fecha;
  final String categoria;
  String? vehiculo_id;

  
  
  factory Gasto.fromMap(Map<String, dynamic> map){
    return Gasto(
      descripcion: map['descripcion'],
      lugar: map['lugar'],
      cantidad: map['cantidad'],
      fecha: map['fecha'],
      vehiculo_id: map['vehiculo_id'],
      categoria: map['categoria'],

    );
  }

  Gasto({required this.descripcion, required this.lugar, required this.cantidad, required this.fecha, required this.categoria, this.vehiculo_id});




  @override
  List<Object?> get props => [descripcion, lugar, cantidad, fecha, vehiculo_id, categoria];

} 
