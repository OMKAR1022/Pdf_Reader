import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class ZipToPdfState extends Equatable {
  const ZipToPdfState();

  @override
  List<Object?> get props => [];
}

class ZipToPdfInitial extends ZipToPdfState {}

class ZipToPdfLoading extends ZipToPdfState {}

class ZipToPdfLoaded extends ZipToPdfState {
  final String zipPath;
  final List<File> images;

  const ZipToPdfLoaded({
    required this.zipPath,
    required this.images,
  });

  @override
  List<Object?> get props => [zipPath, images];
}

class ZipToPdfSuccess extends ZipToPdfState {
  final String pdfPath;

  const ZipToPdfSuccess(this.pdfPath);

  @override
  List<Object?> get props => [pdfPath];
}

class ZipToPdfError extends ZipToPdfState {
  final String message;

  const ZipToPdfError(this.message);

  @override
  List<Object?> get props => [message];
}
