import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "package:image_picker/image_picker.dart";
import "package:material_symbols_icons/symbols.dart";

import "../../../../core/constants/app_routes.dart";
import "../../../../core/errors/app_exception.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_typography.dart";
import "../../../../core/utils/validators.dart";
import "../../../../core/widgets/app_error_view.dart";
import "../../../../core/widgets/app_loader.dart";
import "../../../../core/widgets/app_text_field.dart";
import "../../../../core/widgets/primary_button.dart";
import "../../../auth/presentation/widgets/phone_field.dart";
import "../../domain/entities/fiche_grossiste.dart";
import "../providers/grossiste_providers.dart";

/// Volet 1/2 de l'assistant "Créer ma fiche" (écran 22 de la maquette).
///
/// Flux corrigé — wizard en 2 volets seulement :
///   1/2 : Infos entreprise + photo de profil (ce volet)
///   2/2 : Documents → soumission → attente de validation
///
/// Le paiement de l'abonnement n'est PAS dans le wizard. Il intervient
/// uniquement après validation des documents par l'équipe MboaLink,
/// depuis l'onglet "Profil" du dashboard (état enAttenteAbonnement).
class GrossisteFicheStep1Screen extends ConsumerWidget {
  const GrossisteFicheStep1Screen({this.modeEdition = false, super.key});

  /// true quand cet écran est ouvert depuis "Modifier mes informations"
  /// (fiche déjà validée) plutôt que depuis le wizard d'inscription : on
  /// revient en arrière après enregistrement au lieu d'enchaîner sur le
  /// volet documents.
  final bool modeEdition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ficheAsync = ref.watch(maFicheProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      body: SafeArea(
        child: ficheAsync.when(
          loading: () => const Center(child: AppLoader()),
          error: (error, _) => AppErrorView(
            error: error,
            fallbackMessage: "Impossible de charger votre fiche.",
            onRetry: () => ref.invalidate(maFicheProvider),
          ),
          data: (fiche) => _Step1Form(fiche: fiche, modeEdition: modeEdition),
        ),
      ),
    );
  }
}

class _Step1Form extends ConsumerStatefulWidget {
  const _Step1Form({required this.fiche, this.modeEdition = false});

  final FicheGrossiste fiche;
  final bool modeEdition;

  @override
  ConsumerState<_Step1Form> createState() => _Step1FormState();
}

class _Step1FormState extends ConsumerState<_Step1Form> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nom;
  late final TextEditingController _description;
  late final TextEditingController _secteur;
  late final TextEditingController _ville;
  late final TextEditingController _quartier;
  late final TextEditingController _adresse;
  late final TextEditingController _telephone;
  late final TextEditingController _emailPro;
  late final TextEditingController _siteWeb;

  XFile? _photo;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final f = widget.fiche;
    _nom = TextEditingController(text: f.nomEntreprise ?? "");
    _description = TextEditingController(text: f.description ?? "");
    _secteur = TextEditingController(text: f.secteurActivite ?? "");
    _ville = TextEditingController(text: f.ville ?? "");
    _quartier = TextEditingController(text: f.quartier ?? "");
    _adresse = TextEditingController(text: f.adresseComplete ?? "");
    _telephone = TextEditingController(
      text: (f.telephoneProfessionnel ?? "").replaceFirst("+237", ""),
    );
    _emailPro = TextEditingController(text: f.emailProfessionnel ?? "");
    _siteWeb = TextEditingController(text: f.siteWeb ?? "");
  }

  @override
  void dispose() {
    _nom.dispose();
    _description.dispose();
    _secteur.dispose();
    _ville.dispose();
    _quartier.dispose();
    _adresse.dispose();
    _telephone.dispose();
    _emailPro.dispose();
    _siteWeb.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
    );
    if (file != null) setState(() => _photo = file);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_photo == null &&
        (widget.fiche.logoUrl == null || widget.fiche.logoUrl!.isEmpty)) {
      setState(() => _errorMessage = "La photo de profil est obligatoire.");
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final donnees = {
      "nomEntreprise": _nom.text.trim(),
      "description": _description.text.trim(),
      "secteurActivite": _secteur.text.trim(),
      "ville": _ville.text.trim(),
      "quartier": _quartier.text.trim(),
      "adresseComplete": _adresse.text.trim(),
      "telephoneProfessionnel": "+237${_telephone.text.trim()}",
      "emailProfessionnel": _emailPro.text.trim(),
      if (_siteWeb.text.trim().isNotEmpty) "siteWeb": _siteWeb.text.trim(),
      // Le logo est uploadé séparément après création/mise à jour de la
      // fiche (il faut son id) — on garde ici l'URL existante, si elle y est.
      if (widget.fiche.logoUrl != null) "logoUrl": widget.fiche.logoUrl,
    };

    try {
      final repo = ref.read(grossisteRepositoryProvider);
      // Pas encore de fiche (id vide) → création (POST). Sinon → mise à
      // jour de la fiche existante (PUT).
      var fiche = widget.fiche.id.isEmpty
          ? await repo.creerFiche(donnees)
          : await repo.mettreAJourFiche(
              ficheId: widget.fiche.id,
              donnees: donnees,
            );

      if (_photo != null) {
        final bytes = await _photo!.readAsBytes();
        final extension = _photo!.path.split(".").last;
        fiche = await repo.uploaderLogo(
          ficheId: fiche.id,
          extension: extension,
          bytes: bytes,
        );
      }

      ref.invalidate(maFicheProvider);
      if (!mounted) return;
      if (widget.modeEdition) {
        context.pop();
      } else {
        context.push(AppRoutes.grossisteFicheStep2, extra: fiche.id);
      }
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

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isTablet ? 480 : double.infinity),
        child: Column(
          children: [
            // En-tête
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
                    widget.modeEdition ? "Modifier ma fiche" : "Créer ma fiche",
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Barre de progression 1/2 — masquée en mode édition (pas un wizard)
            if (!widget.modeEdition)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "1/2",
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

            // Formulaire
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Informations de l'entreprise",
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Visible par les clients une fois votre fiche validée.",
                        style: AppTypography.bodySmall,
                      ),
                      const SizedBox(height: 18),

                      // Photo de profil (obligatoire — revue de changement)
                      GestureDetector(
                        onTap: _pickPhoto,
                        child: Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: _photo != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(19),
                                  child: Image.file(
                                    File(_photo!.path),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : (widget.fiche.logoUrl != null &&
                                    widget.fiche.logoUrl!.isNotEmpty &&
                                    !widget.fiche.logoUrl!.startsWith(
                                      "mock://",
                                    ))
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(19),
                                  child: Image.network(
                                    widget.fiche.logoUrl!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Symbols.add_a_photo,
                                      size: 26,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Photo *",
                                      style: AppTypography.caption.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      AppTextField(
                        label: "Nom de l'entreprise",
                        controller: _nom,
                        validator: (v) => Validators.required(
                          v,
                          message: "Le nom de l'entreprise est obligatoire.",
                        ),
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: "Description de l'activité",
                        controller: _description,
                        validator: (v) => Validators.required(
                          v,
                          message: "La description est obligatoire.",
                        ),
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: "Secteur d'activité",
                        controller: _secteur,
                        hintText: "Ex : Vivres & alimentation",
                        validator: (v) => Validators.required(
                          v,
                          message: "Le secteur d'activité est obligatoire.",
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: "Ville",
                              controller: _ville,
                              validator: (v) => Validators.required(
                                v,
                                message: "La ville est obligatoire.",
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: AppTextField(
                              label: "Quartier",
                              controller: _quartier,
                              validator: (v) => Validators.required(
                                v,
                                message: "Le quartier est obligatoire.",
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: "Adresse complète",
                        controller: _adresse,
                        validator: (v) => Validators.required(
                          v,
                          message: "L'adresse est obligatoire.",
                        ),
                      ),
                      const SizedBox(height: 14),
                      PhoneField(
                        controller: _telephone,
                        label: "Téléphone professionnel",
                        validator: Validators.phoneRequired,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: "Email professionnel",
                        controller: _emailPro,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: "Site web (optionnel)",
                        controller: _siteWeb,
                        keyboardType: TextInputType.url,
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
                      const SizedBox(height: 22),
                      PrimaryButton(
                        label: widget.modeEdition ? "Enregistrer" : "Continuer",
                        trailingIcon: widget.modeEdition
                            ? null
                            : Symbols.arrow_forward,
                        isLoading: _isSubmitting,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
