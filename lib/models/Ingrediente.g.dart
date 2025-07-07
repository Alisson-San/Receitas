// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Ingrediente.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ingrediente _$IngredienteFromJson(Map<String, dynamic> json) => Ingrediente(
  id: json['id'] as String?,
  receitaId: json['receitaId'] as String?,
  nome: json['nome'] as String?,
  quantidade: json['quantidade'] as String?,
);

Map<String, dynamic> _$IngredienteToJson(Ingrediente instance) =>
    <String, dynamic>{
      'id': instance.id,
      'receitaId': instance.receitaId,
      'nome': instance.nome,
      'quantidade': instance.quantidade,
    };
