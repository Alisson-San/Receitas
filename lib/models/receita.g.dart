// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receita.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Receita _$ReceitaFromJson(Map<String, dynamic> json) => Receita(
  id: json['id'] as String?,
  nome: json['nome'] as String?,
  dataCriacao: json['dataCriacao'] as String?,
  ingredientes:
      (json['ingredientes'] as List<dynamic>)
          .map((e) => Ingrediente.fromJson(e as Map<String, dynamic>))
          .toList(),
  instrucoes:
      (json['instrucoes'] as List<dynamic>)
          .map((e) => Instrucao.fromJson(e as Map<String, dynamic>))
          .toList(),
  userId: json['userId'] as String?,
);

Map<String, dynamic> _$ReceitaToJson(Receita instance) => <String, dynamic>{
  'id': instance.id,
  'nome': instance.nome,
  'dataCriacao': instance.dataCriacao,
  'ingredientes': instance.ingredientes.map((e) => e.toJson()).toList(),
  'instrucoes': instance.instrucoes.map((e) => e.toJson()).toList(),
  'userId': instance.userId,
};
