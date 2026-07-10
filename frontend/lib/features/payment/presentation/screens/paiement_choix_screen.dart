import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "package:material_symbols_icons/symbols.dart";

import "../../../../core/constants/app_routes.dart";
import "../../../../core/errors/app_exception.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_typography.dart";
import "../../../../core/utils/validators.dart";
import "../../../../core/widgets/primary_button.dart";
import "../../../auth/presentation/widgets/phone_field.dart";
import "../../domain/entities/paiement_params.dart";
import "../../domain/entities/transaction_paiement.dart";
import "../providers/payment_providers.dart";

/// Écran 12 · Choix du paiement — initie une transaction Mobile Money
/// (MTN ou Orange) via POST /transactions, puis pousse vers l'écran de
/// confirmation qui attend la validation sur le téléphone de l'utilisateur.
class PaiementChoixScreen extends ConsumerStatefulWidget {
  const PaiementChoixScreen({required this.params, super.key});

  final PaiementParams params;

  @override
  ConsumerState<PaiementChoixScreen> createState() =>
      _PaiementChoixScreenState();
}

class _PaiementChoixScreenState extends ConsumerState<PaiementChoixScreen> {
  final _formKey = GlobalKey<FormState>();
  final _telephone = TextEditingController();
  OperateurMobileMoney _operateur = OperateurMobileMoney.mtnMomo;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _telephone.dispose();
    super.dispose();
  }

  Future<void> _payer() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final transaction = await ref
          .read(paymentRepositoryProvider)
          .initierPaiement(
            type: widget.params.type,
            montant: widget.params.montant,
            operateur: _operateur,
            numeroTelephone: "237${_telephone.text.trim()}",
            description: widget.params.description,
            ficheGrossisteId: widget.params.ficheGrossisteId,
          );
      if (!mounted) return;
      context.push(
        AppRoutes.paiementConfirmation,
        extra: {"transaction": transaction, "params": widget.params},
      );
    } on AppException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 480 : double.infinity,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: const Icon(
                          Symbols.arrow_back,
                          size: 23,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Paiement",
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.params.description,
                                        style: AppTypography.caption,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "${widget.params.montant.toStringAsFixed(0)} FCFA",
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  widget.params.type ==
                                          TypeTransaction
                                              .deverrouillageCoordonnees
                                      ? Symbols.lock_open
                                      : Symbols.workspace_premium,
                                  size: 30,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            "MOYEN DE PAIEMENT",
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _OperateurTile(
                            label: "MTN Mobile Money",
                            badge: "MTN",
                            badgeColor: const Color(0xFFFFCC00),
                            badgeTextColor: AppColors.textPrimary,
                            isSelected:
                                _operateur == OperateurMobileMoney.mtnMomo,
                            onTap: () => setState(
                              () => _operateur = OperateurMobileMoney.mtnMomo,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _OperateurTile(
                            label: "Orange Money",
                            badge: "OM",
                            badgeColor: const Color(0xFFFF6600),
                            badgeTextColor: Colors.white,
                            isSelected:
                                _operateur == OperateurMobileMoney.orangeMoney,
                            onTap: () => setState(
                              () =>
                                  _operateur = OperateurMobileMoney.orangeMoney,
                            ),
                          ),
                          const SizedBox(height: 18),
                          PhoneField(
                            controller: _telephone,
                            label: "Numéro de paiement",
                            validator: Validators.phoneRequired,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Symbols.shield,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 7),
                              Expanded(
                                child: Text(
                                  "Paiement sécurisé · données non stockées.",
                                  style: AppTypography.caption,
                                ),
                              ),
                            ],
                          ),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 14),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.errorBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 11, 20, 24),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: PrimaryButton(
                    label:
                        "Payer ${widget.params.montant.toStringAsFixed(0)} FCFA",
                    trailingIcon: Symbols.lock,
                    isLoading: _isSubmitting,
                    onPressed: _payer,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OperateurTile extends StatelessWidget {
  const _OperateurTile({
    required this.label,
    required this.badge,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String badge;
  final Color badgeColor;
  final Color badgeTextColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFFDF5) : AppColors.surface,
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  badge,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: badgeTextColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(
              isSelected
                  ? Symbols.check_circle
                  : Symbols.radio_button_unchecked,
              size: 22,
              color: isSelected ? AppColors.primary : AppColors.textFaint,
              fill: isSelected ? 1 : 0,
            ),
          ],
        ),
      ),
    );
  }
}
