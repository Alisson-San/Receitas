// models/receita.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:receita/models/Ingrediente.dart';
import 'package:receita/models/Instrucao.dart';

part 'receita.g.dart';

@JsonSerializable(explicitToJson: true) 
class Receita {
  String? id;
  String? nome;
  String? dataCriacao;
  List<Ingrediente> ingredientes;
  List<Instrucao> instrucoes;
  String? userId;

  Receita({
    this.id,
    this.nome,
    this.dataCriacao,
    this.ingredientes = const [],
    this.instrucoes = const [],
    this.userId,
  });

  factory Receita.fromJson(Map<String, dynamic> json) => _$ReceitaFromJson(json);
  Map<String, dynamic> toJson() => _$ReceitaToJson(this);

  Map<String, dynamic> toSqliteMap() {
    return {
      'id': id,
      'nome': nome,
      'dataCriacao': dataCriacao,
      'userId': userId,
    };
  }

  // fromMap() para SQLite - mantém como estava
  factory Receita.fromMap(Map<String, dynamic> map) {
    return Receita(
      id: map['id'],
      nome: map['nome'],
      dataCriacao: map['dataCriacao'],
      userId: map['userId'],
      ingredientes: [], 
      instrucoes: [], 
    );
  }
}