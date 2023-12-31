// ignore_for_file: non_constant_identifier_names

import 'package:equatable/equatable.dart';

class Categoria with EquatableMixin{
  
  final String nombre;
  int categoria_id;

  factory Categoria.fromMap(Map<String, dynamic> map){
    return Categoria(
      categoria_id: map['id'],
      nombre: map['categoria'],

      
      );
  }

  Categoria({required this.nombre, required this.categoria_id});

  
  
  @override
  List<Object?> get props => [categoria_id, nombre];
  
}