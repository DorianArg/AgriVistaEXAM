# AgriVista Field

## Présentation

AgriVista Field est une application Flutter interne destinée aux techniciens qui installent et entretiennent les stations de capteurs connectés d’AgriVista. Elle charge les interventions depuis un JSON distant, accompagne leur traitement sur le terrain et conserve localement les informations qui ne sont pas synchronisées avec le serveur.

## Fonctionnalités principales

- chargement du JSON distant avec Dio et désérialisation typée ;
- liste des interventions avec états loading, data, empty et error ;
- recherche par station, domaine ou description ;
- filtres par statut (`planifiee`, `en_cours`, `terminee`) et priorité ;
- détail complet : station, domaine, coordonnées, priorité, statut, date prévue, description et historique ;
- progression contrôlée du statut `planifiee → en_cours → terminee` ;
- persistance locale des changements de statut avec Hive ;
- message d’erreur explicite et action « Réessayer » après un échec initial ;
- profil alimenté par les données du technicien ;
- navigation Material 3 entre Dashboard, Interventions et Profil.

## Extensions optionnelles réalisées

- dashboard de synthèse avec compteurs par statut et priorité ;
- pull-to-refresh conservant la dernière liste valide en cas d’échec ;
- tri par date prévue, priorité ou statut, en ordre croissant ou décroissant ;
- note terrain locale propre à chaque intervention ;
- sélection, copie permanente et remplacement d’une photo locale ;
- thèmes Système, Clair et Sombre, avec préférence persistée ;
- interface responsive avec `NavigationBar` sur téléphone et `NavigationRail` sur tablette ;
- master/detail tablette : liste à gauche et détail sélectionné à droite.

## Architecture

Le projet suit une Clean Architecture :

```text
Presentation → Domain ← Data
```

- **Domain** : entités, règles métier, contrats de repositories et cas d’usage en Dart pur. Aucun import Flutter, Riverpod, Dio ou Hive.
- **Data** : DTO, parsing JSON, mappers, sources Dio/Hive, gestion des fichiers photo et implémentations des repositories.
- **Presentation** : pages et widgets Flutter, providers Riverpod, filtres, tri et états d’interface.
- **Composition root** : `lib/app/bootstrap.dart` initialise Hive et injecte les implémentations techniques dans `ProviderScope`.

Flux principal :

```text
UI → Riverpod → Use case → Repository → Data source
```

## Organisation du repository

```text
.
├── android/                 # cible Android
├── ios/                     # cible iOS générée et configurée
├── docs/                    # sujet et documents de livraison
├── lib/
│   ├── app/                 # application, shell et composition root
│   ├── core/                # erreurs, réseau, thèmes, responsive, widgets communs
│   └── features/
│       ├── dashboard/       # synthèse des interventions
│       ├── interventions/
│       │   ├── data/
│       │   ├── domain/
│       │   └── presentation/
│       └── profile/         # profil et sélection du thème
├── test/                    # tests unitaires, providers et widgets
├── pubspec.yaml
└── README.md
```

## Stack technique

Versions résolues dans `pubspec.lock` :

| Technologie | Version | Rôle |
|---|---:|---|
| Flutter | 3.44.8 | framework et Material 3 |
| Dart | 3.12.2 | langage |
| flutter_riverpod | 3.4.2 | état et injection de dépendances |
| dio | 5.11.0 | client HTTP |
| freezed / freezed_annotation | 3.2.5 / 3.1.0 | DTO immuables et génération |
| json_serializable / json_annotation | 6.14.1 / 4.12.0 | désérialisation JSON |
| hive_flutter / hive | 1.1.0 / 2.2.3 | persistance locale |
| image_picker | 1.2.3 | sélection d’une photo dans la galerie |
| path_provider | 2.1.6 | accès au stockage permanent de l’application |

## Source JSON

`https://utrera.ludovic.aflokkat-projet.fr/getInterventions.json`

- requête HTTP GET et source distante en lecture seule ;
- connexion nécessaire au premier chargement et à chaque actualisation ;
- pas de cache complet du JSON ;
- le JSON reste la référence pour le technicien, les interventions et l’historique ;
- les valeurs locales autorisées surchargent uniquement les champs concernés.

## Persistance locale

Hive utilise quatre boxes :

| Box | Contenu |
|---|---|
| `intervention_statuses` | statut local par identifiant d’intervention |
| `intervention_notes` | note locale par intervention |
| `intervention_photos` | chemin de la photo permanente par intervention |
| `app_preferences` | préférence `theme_mode` (`system`, `light`, `dark`) |

Les photos ne sont pas stockées dans Hive. Après sélection, elles sont copiées dans le répertoire permanent de l’application fourni par `path_provider`; Hive conserve uniquement leur chemin. Lors d’un remplacement réussi, l’ancienne copie gérée par l’application est supprimée.

## Installation et lancement

Prérequis : Flutter, Dart, Android SDK et un appareil ou émulateur Android. La compilation iOS nécessite macOS et Xcode.

```bash
git clone https://github.com/DorianArg/AgriVistaEXAM.git
cd AgriVistaEXAM
flutter pub get
flutter run
```

Les fichiers générés sont versionnés. Après modification des DTO :

```bash
dart run build_runner build
```

## Tests et build

```bash
dart format .
flutter analyze
flutter test
flutter build apk --debug
```

La suite compte **172 tests automatisés réussis** : Domain, parsing et mapping JSON, erreurs Dio, Hive, repositories, Riverpod, recherche, filtres, tri, refresh, dashboard, détail, statut, note, photo, thèmes, navigation et layouts téléphone/tablette. Aucun pourcentage de couverture n’est annoncé.

## Validation des plateformes

- **Android** : APK debug construit. L’application a été installée et lancée sur un Samsung SM S926U sous Android 16/API 36. Un parcours tactile photo complet et la conservation manuelle du thème après fermeture/reprise ne sont pas revendiqués.
- **Tablette** : layouts vérifiés par tests widgets à 1200 × 900, sans tablette physique ni émulateur tablette.
- **iOS** : projet généré et accès à la photothèque configuré. Aucune compilation iOS n’a été exécutée dans l’environnement Windows ; elle nécessite macOS/Xcode.

## Limites

- premier chargement et actualisations dépendants du réseau ;
- absence de cache JSON complet offline-first ;
- statuts, notes et photos non synchronisés avec un serveur ;
- aucune authentification réelle ni résolution de conflit ;
- historique distant non enrichi localement ;
- photo choisie depuis la galerie uniquement ;
- aucune validation manuelle sur tablette ou iOS.

## Livrables

### Documents de remise

- [Sujet officiel](docs/25-26_mespr-flutter.pdf)
- [Dossier de conception v1.1 — PDF](docs/Dossier_conception_AgriVista_Field_Dorian_ARGAILLOT_v1_1.pdf)
- [Dossier technique — PDF](docs/Dossier_technique_AgriVista_Field_Dorian_ARGAILLOT.pdf)

### Source éditable

- [Dossier technique final — Markdown](docs/dossier_technique.md)

Les PDF sont les formats destinés à la remise. Le Markdown constitue la source textuelle actualisée du dossier technique.
