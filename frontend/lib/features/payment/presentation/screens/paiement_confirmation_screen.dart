import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "package:material_symbols_icons/symbols.dart";

import "../../../../core/constants/app_routes.dart";
import "../../../../core/errors/app_exception.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/widgets/primary_button.dart";
import "../../../grossiste/presentation/providers/grossiste_providers.dart";
import "../../../home/presentation/providers/home_providers.dart";
import "../../domain/entities/paiement_params.dart";
import "../../domain/entities/transaction_paiement.dart";
import "../providers/payment_providers.dart";

enum _Etape { attente, succes, echec }

/// Écran 13 · Confirmation Mobile Money — interroge Campay toutes les
/// 3 secondes jusqu'à SUCCES/ECHEC (environ 2 min max), puis termine
/// l'action métier associée (création/renouvellement d'abonnement, ou
/// récupération des coordonnées déverrouillées).
class PaiementConfirmationScreen extends ConsumerStatefulWidget {
  const PaiementConfirmationScreen({
    required this.transaction,
    required this.params,
    super.key,
  });

  final TransactionPaiement transaction;
  final PaiementParams params;

  @override
  ConsumerState<PaiementConfirmationScreen> createState() =>
      _PaiementConfirmationScreenState();
}

class _PaiementConfirmationScreenState
    extends ConsumerState<PaiementConfirmationScreen> {
  static const _intervalle = Duration(seconds: 3);
  static const _tentativesMax = 40; // ~2 minutes

  Timer? _timer;
  int _tentatives = 0;
  _Etape _etape = _Etape.attente;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _demarrerPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _demarrerPolling() {
    _timer = Timer.periodic(_intervalle, (_) => _verifier());
  }

  Future<void> _verifier() async {
    _tentatives++;
    try {
      final statut = await ref
          .read(paymentRepositoryProvider)
          .verifierStatut(widget.transaction.id);

      if (statut == StatutTransaction.succes) {
        _timer?.cancel();
        await _finaliser();
      } else if (statut == StatutTransaction.echec) {
        _timer?.cancel();
        if (mounted) setState(() => _etape = _Etape.echec);
      } else if (_tentatives >= _tentativesMax) {
        _timer?.cancel();
        if (mounted) {
          setState(() {
            _etape = _Etape.echec;
            _erreur = "Délai dépassé. Réessayez si le paiement n'a pas abouti.";
          });
        }
      }
    } on AppException {
      // Erreur réseau ponctuelle — on retente au prochain cycle plutôt
      // que d'échouer immédiatement.
      if (_tentatives >= _tentativesMax) {
        _timer?.cancel();
        if (mounted) setState(() => _etape = _Etape.echec);
      }
    }
  }

  Future<void> _finaliser() async {
    try {
      switch (widget.params.type) {
        case TypeTransaction.abonnement:
          final repo = ref.read(paymentRepositoryProvider);
          if (widget.params.abonnementExistant) {
            await repo.renouvelerAbonnement(
              transactionId: widget.transaction.id,
            );
          } else {
            await repo.creerAbonnement(
              typeAbonnement: widget.params.typeAbonnement!,
              montant: widget.params.montant,
              renouvellementAuto: false,
              transactionId: widget.transaction.id,
            );
          }
          ref.invalidate(monAbonnementProvider);
          ref.invalidate(maFicheProvider);
        case TypeTransaction.reinitialisationNote:
          await ref
              .read(paymentRepositoryProvider)
              .reinitialiserNote(
                ficheGrossisteId: widget.params.ficheGrossisteId!,
                transactionId: widget.transaction.id,
              );
          ref.invalidate(maFicheProvider);
        case TypeTransaction.certificationPremium:
          await ref
              .read(paymentRepositoryProvider)
              .demanderCertification(
                ficheGrossisteId: widget.params.ficheGrossisteId!,
                transactionId: widget.transaction.id,
              );
          ref.invalidate(maFicheProvider);
        case TypeTransaction.deverrouillageCoordonnees:
          final coordonnees = await ref
              .read(rechercheRepositoryProvider)
              .deverrouiller(
                ficheId: widget.params.ficheGrossisteId!,
                transactionId: widget.transaction.id,
                montantPaye: widget.params.montant,
              );
          ref.invalidate(
            estDeverrouilleProvider(widget.params.ficheGrossisteId!),
          );
          if (!mounted) return;
          context.pushReplacement(
            AppRoutes.coordonneesDebloquees,
            extra: coordonnees,
          );
          return;
      }
      if (mounted) setState(() => _etape = _Etape.succes);
    } on AppException catch (e) {
      if (mounted) {
        setState(() {
          _etape = _Etape.echec;
          _erreur = e.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1F17),
      body: SafeArea(
        child: switch (_etape) {
          _Etape.attente => _AttenteView(
            operateur: widget.transaction.operateur,
            montant: widget.params.montant,
          ),
          _Etape.succes => _SuccesView(params: widget.params),
          _Etape.echec => _EchecView(message: _erreur),
        },
      ),
    );
  }
}

class _AttenteView extends StatelessWidget {
  const _AttenteView({required this.operateur, required this.montant});

  final String operateur;
  final double montant;

  @override
  Widget build(BuildContext context) {
    final estMtn = operateur == "MTN_MOMO";
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: estMtn
                          ? const Color(0xFFFFCC00)
                          : const Color(0xFFFF6600),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        estMtn ? "MTN" : "OM",
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: estMtn ? AppColors.textPrimary : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Confirmez sur votre téléphone",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text.rich(
                    TextSpan(
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.7),
                        height: 1.55,
                      ),
                      children: [
                        const TextSpan(text: "Validez la notification "),
                        TextSpan(
                          text: estMtn ? "MTN MoMo" : "Orange Money",
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text:
                              " pour autoriser le paiement de ${montant.toStringAsFixed(0)} FCFA.",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      3,
                      (i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3.5),
                        child: _PulsingDot(delay: i * 200),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    "En attente de confirmation…",
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 36),
          child: TextButton(
            onPressed: () => context.pop(),
            child: Text(
              "Annuler",
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.delay});

  final int delay;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(
        begin: 0.3,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: Container(
        width: 9,
        height: 9,
        decoration: const BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _SuccesView extends StatelessWidget {
  const _SuccesView({required this.params});

  final PaiementParams params;

  @override
  Widget build(BuildContext context) {
    final estAbonnement = params.type == TypeTransaction.abonnement;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Symbols.check_circle,
                size: 42,
                color: AppColors.primary,
                fill: 1,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              estAbonnement ? "Abonnement activé !" : "Paiement réussi !",
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              estAbonnement
                  ? "Votre fiche est maintenant visible dans l'annuaire MboaLink."
                  : "Votre paiement a bien été confirmé.",
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: "Continuer",
                onPressed: () => context.go(AppRoutes.grossisteDashboard),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EchecView extends StatelessWidget {
  const _EchecView({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Symbols.error,
                size: 42,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              "Paiement échoué",
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message ??
                  "Le paiement n'a pas pu être confirmé. Vérifiez votre solde et réessayez.",
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: "Réessayer",
                onPressed: () => context.pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
