import 'package:equatable/equatable.dart';

class PdfFileModel extends Equatable {
  final String path;
  final String name;
  final DateTime createdAt;
  final int pageCount;
  final int fileSizeBytes;

  const PdfFileModel({
    required this.path,
    required this.name,
    required this.createdAt,
    this.pageCount = 0,
    this.fileSizeBytes = 0,
  });

  factory PdfFileModel.fromJson(Map<String, dynamic> json) {
    return PdfFileModel(
      path: json['path'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      pageCount: json['pageCount'] as int? ?? 0,
      fileSizeBytes: json['fileSizeBytes'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'pageCount': pageCount,
      'fileSizeBytes': fileSizeBytes,
    };
  }

  @override
  List<Object?> get props => [path, name, createdAt, pageCount, fileSizeBytes];
}
