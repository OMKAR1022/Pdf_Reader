import 'package:equatable/equatable.dart';

abstract class PasswordProtectEvent extends Equatable {
  const PasswordProtectEvent();

  @override
  List<Object?> get props => [];
}

class LoadPdfForProtection extends PasswordProtectEvent {
  final String path;

  const LoadPdfForProtection(this.path);

  @override
  List<Object?> get props => [path];
}

class ProtectPdf extends PasswordProtectEvent {
  final String userPassword;
  final String? ownerPassword;

  const ProtectPdf({
    required this.userPassword,
    this.ownerPassword,
  });

  @override
  List<Object?> get props => [userPassword, ownerPassword];
}
