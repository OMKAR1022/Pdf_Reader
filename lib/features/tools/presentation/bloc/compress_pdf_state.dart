import 'package:equatable/equatable.dart';

abstract class CompressPdfState extends Equatable {
  const CompressPdfState();

  @override
  List<Object?> get props => [];
}

class CompressPdfInitial extends CompressPdfState {}

class CompressPdfLoading extends CompressPdfState {}

class CompressPdfLoaded extends CompressPdfState {
  final String originalPath;
  final int originalSize;
  final String? compressedPath;
  final int? compressedSize;

  const CompressPdfLoaded({
    required this.originalPath,
    required this.originalSize,
    this.compressedPath,
    this.compressedSize,
  });

  CompressPdfLoaded copyWith({
    String? originalPath,
    int? originalSize,
    String? compressedPath,
    int? compressedSize,
  }) {
    return CompressPdfLoaded(
      originalPath: originalPath ?? this.originalPath,
      originalSize: originalSize ?? this.originalSize,
      compressedPath: compressedPath ?? this.compressedPath,
      compressedSize: compressedSize ?? this.compressedSize,
    );
  }

  @override
  List<Object?> get props => [originalPath, originalSize, compressedPath, compressedSize];
}

class CompressPdfError extends CompressPdfState {
  final String message;

  const CompressPdfError(this.message);

  @override
  List<Object?> get props => [message];
}
