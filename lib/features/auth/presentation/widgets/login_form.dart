import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app_colors.dart';
import '../../application/auth_provider.dart';
import 'login_text_field.dart';

enum LoginStyle { web, mobile }

/// Form email + kata sandi. Tampilan field/tombol mengikuti [style].
class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({
    super.key,
    required this.title,
    required this.subtitle,
    required this.style,
  });

  final String title;
  final String subtitle;
  final LoginStyle style;

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _emailC.dispose();
    _passC.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Email wajib diisi';
    if (!_emailRegex.hasMatch(value)) return 'Format email tidak valid';
    return null;
  }

  String? _validatePassword(String? v) {
    final value = v ?? '';
    if (value.isEmpty) return 'Kata sandi wajib diisi';
    if (value.length < 6) return 'Kata sandi minimal 6 karakter';
    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ref.read(authRepositoryProvider).signIn(
            email: _emailC.text,
            password: _passC.text,
          );
      // Sukses: tidak perlu navigasi manual. authStateProvider berubah dan
      // redirect di router memindahkan user ke /dashboard.
    } on AuthFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = widget.style == LoginStyle.mobile;
    final fill = isMobile ? Colors.white : const Color(0xFFF4F6FA);
    final border =
        isMobile ? const Color(0xFFC9D3DF) : const Color(0xFFDCE3EB);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            widget.subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          LoginTextField(
            label: 'Email',
            hint: 'Masukkan email Anda',
            icon: isMobile ? Icons.person_outline : Icons.mail_outline,
            controller: _emailC,
            fillColor: fill,
            borderColor: border,
            validator: _validateEmail,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
          ),
          const SizedBox(height: 16),
          LoginTextField(
            label: 'Kata Sandi',
            hint: 'Masukkan kata sandi',
            icon: Icons.lock_outline,
            controller: _passC,
            fillColor: fill,
            borderColor: border,
            validator: _validatePassword,
            obscureText: _obscure,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            autofillHints: const [AutofillHints.password],
            suffix: IconButton(
              tooltip: _obscure ? 'Tampilkan kata sandi' : 'Sembunyikan kata sandi',
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(
                _obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            _ErrorBox(message: _error!),
          ],
          const SizedBox(height: 24),
          _SubmitButton(
            loading: _loading,
            gradient: isMobile,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

/// Pesan gagal login (token warna Bahaya).
class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bahayaBannerBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 18,
            color: AppColors.bahayaBannerTitle,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.bahayaBannerTitle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.loading,
    required this.gradient,
    required this.onPressed,
  });

  final bool loading;
  final bool gradient;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: gradient ? null : AppColors.primaryButton,
          gradient: gradient
              ? const LinearGradient(
                  colors: [Color(0xFF0A1E2D), AppColors.primaryButton],
                )
              : null,
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryButton.withValues(alpha: 0.30),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: radius,
            onTap: loading ? null : onPressed,
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Masuk ke Dashboard',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
