import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/view_status.dart';
import '../controller/lock_controller.dart';

/// Uygulama Kilidi ve PIN Giriş Ekranı (Sümeyye - T23)
class LockView extends StatefulWidget {
  final LockController controller;
  final VoidCallback onUnlocked;

  const LockView({
    super.key,
    required this.controller,
    required this.onUnlocked,
  });

  @override
  State<LockView> createState() => _LockViewState();
}

class _LockViewState extends State<LockView> {
  final TextEditingController _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _tryBiometrics() async {
    final bool success = await widget.controller.unlockWithBiometrics();
    if (success && mounted) {
      widget.onUnlocked();
    }
  }

  Future<void> _unlockWithPin() async {
    final bool success = await widget.controller.unlockWithPin(_pinController.text);
    if (success && mounted) {
      widget.onUnlocked();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildPinField(),
              const SizedBox(height: 16),
              _buildErrorMessage(),
              const SizedBox(height: 16),
              _buildUnlockButton(),
              const SizedBox(height: 12),
              _buildBiometricsButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: const Icon(Icons.lock_outline, size: 36, color: AppColors.primary),
        ),
        const SizedBox(height: 16),
        const Text(
          'SafeRentHouse Kilitli',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Delil ve sözleşme kayıtlarınıza erişmek için PIN kodunuzu girin.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: AppColors.lightTextSecondary),
        ),
      ],
    );
  }

  Widget _buildPinField() {
    return TextField(
      controller: _pinController,
      obscureText: true,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      maxLength: 8,
      style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
      decoration: const InputDecoration(
        hintText: '••••',
        counterText: '',
        prefixIcon: Icon(Icons.pin_outlined),
      ),
      onSubmitted: (_) => _unlockWithPin(),
    );
  }

  Widget _buildErrorMessage() {
    return ValueListenableBuilder<String?>(
      valueListenable: widget.controller.errorMessage,
      builder: (BuildContext context, String? error, _) {
        if (error == null || error.isEmpty) return const SizedBox.shrink();
        return Text(
          error,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w600),
        );
      },
    );
  }

  Widget _buildUnlockButton() {
    return ValueListenableBuilder<ViewStatus>(
      valueListenable: widget.controller.status,
      builder: (BuildContext context, ViewStatus status, _) {
        final bool isLoading = status == ViewStatus.loading;
        return ElevatedButton(
          onPressed: isLoading ? null : _unlockWithPin,
          child: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Kilidi Aç'),
        );
      },
    );
  }

  Widget _buildBiometricsButton() {
    return TextButton.icon(
      onPressed: _tryBiometrics,
      icon: const Icon(Icons.fingerprint),
      label: const Text('Biyometrik (Parmak İzi / Yüz) ile Aç'),
    );
  }
}
