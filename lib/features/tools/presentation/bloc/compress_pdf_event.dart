import 'package:equatable/equatable.dart';

abstract class CompressPdfEvent extends Equatable {
  const CompressPdfEvent();

  @override
  List<Object?> get props => [];
}

class LoadPdfForCompression extends CompressPdfEvent {
  final String path;

  const LoadPdfForCompression(this.path);

  @override
  List<Object?> get props => [path];
}

class CompressPdf extends CompressPdfEvent {
  final int quality; // 0-100

  const CompressPdf(this.quality);

  @override
  List<Object?> get props => [quality];
}
