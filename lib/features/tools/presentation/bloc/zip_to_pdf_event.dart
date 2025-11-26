import 'package:equatable/equatable.dart';

abstract class ZipToPdfEvent extends Equatable {
  const ZipToPdfEvent();

  @override
  List<Object?> get props => [];
}

class LoadZipFile extends ZipToPdfEvent {
  final String path;

  const LoadZipFile(this.path);

  @override
  List<Object?> get props => [path];
}

class CreatePdfFromZip extends ZipToPdfEvent {
  const CreatePdfFromZip();
}
