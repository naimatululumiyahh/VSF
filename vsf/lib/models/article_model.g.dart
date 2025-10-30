// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_model.dart';

// TypeAdapterGenerator

class ArticleModelAdapter extends TypeAdapter<ArticleModel> {
  @override
  final int typeId = 5;

  @override
  ArticleModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ArticleModel(
      id: fields[0] as String,
      title: fields[1] as String,
      imageUrl: fields[2] as String,
      externalLink: fields[3] as String,
      summary: fields[4] as String?,
      category: fields[5] as String,
      publishedAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ArticleModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.imageUrl)
      ..writeByte(3)
      ..write(obj.externalLink)
      ..writeByte(4)
      ..write(obj.summary)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.publishedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArticleModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
