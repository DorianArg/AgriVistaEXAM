# AgriVista Field

## Présentation

AgriVista est une entreprise corse spécialisée dans l’installation et la maintenance de stations de capteurs connectés destinées aux exploitations agricoles et viticoles.

AgriVista Field est une application Flutter interne destinée aux techniciens terrain. Elle permet de consulter les interventions provenant d’un JSON distant, de les rechercher, de les filtrer, d’afficher leur détail et de faire évoluer leur statut. Les modifications de statut sont conservées localement avec Hive.

## Fonctionnalités

- chargement en lecture seule du JSON distant ;
- désérialisation et validation typées ;
- liste des interventions ;
- recherche par station, domaine ou description ;
- filtres par statut et priorité ;
- détail complet : station, domaine, localisation, priorité, statut, date, description et historique ;
- progression `planifiee → en_cours → terminee` ;
- persistance locale des statuts et conservation après redémarrage ;
- états loading, data, empty et error distincts ;
- rechargement manuel avec le bouton « Réessayer » ;
- profil dynamique du technicien ;
- navigation Material 3 entre Interventions et Profil.

## Livrables

### Documents de remise

- [Sujet officiel](docs/25-26_mespr-flutter.pdf) — document PDF fourni par l’équipe pédagogique.
- [Dossier de conception — PDF](docs/Dossier_conception_AgriVista_Field_Dorian_ARGAILLOT.pdf) — version destinée à la remise.
- [Dossier technique — PDF](docs/Dossier_technique_AgriVista_Field_Dorian_ARGAILLOT.pdf) — version destinée à la remise.

Les PDF sont les documents destinés à la remise.

## Organisation du projet

```text
.
├── android/          # cible Android
├── ios/              # cible iOS
├── docs/             # sujet et documentation de remise
├── lib/              # code source Flutter
├── test/             # tests automatisés
├── pubspec.yaml      # dépendances et configuration Flutter
└── README.md         # point d’entrée du repository
```

```text
lib/
├── app/
├── core/
├── features/
│   ├── interventions/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── profile/
└── main.dart
```

### `lib/app`

Démarrage de l’application, composition technique, navigation et configuration applicative.

### `lib/core`

Erreurs typées, client réseau, thème, utilitaires et widgets partagés.

### `features/interventions/domain`

Entités, enums, contrat abstrait du repository, use cases et règles métier.

### `features/interventions/data`

Client Dio, RemoteDataSource, stockage Hive, DTO, mappers et implémentation du repository.

### `features/interventions/presentation`

Pages, widgets, providers Riverpod, filtres et états UI.

### `features/profile`

Page et widgets du profil alimentés par le technicien du provider principal.

## Architecture

Le projet suit une Clean Architecture :

```text
Presentation → Domain ← Data
```

- **Domain** : Dart pur, avec les entités, règles métier, repositories abstraits et use cases. Il ne dépend pas de Flutter, Riverpod, Dio ou Hive.
- **Data** : lecture Dio, JSON, DTO, mapping, Hive et implémentation du repository.
- **Presentation** : pages et widgets Flutter, Riverpod, `AsyncNotifier`, filtres et gestion loading/data/error.

Flux principal :

```text
UI
 ↓
Riverpod
 ↓
Use Case
 ↓
Repository
 ↓
Data Sources
```

## Stack technique

Versions relevées dans l’environnement Flutter et `pubspec.lock` :

| Technologie | Version | Rôle |
|---|---:|---|
| Flutter | 3.44.8 | framework mobile et Material 3 |
| Dart | 3.12.2 | langage de l’application |
| flutter_riverpod | 3.4.2 | gestion d’état et injection de dépendances |
| dio | 5.11.0 | lecture HTTP du JSON |
| freezed / freezed_annotation | 3.2.5 / 3.1.0 | DTO immuables et génération de code |
| json_serializable / json_annotation | 6.14.1 / 4.12.0 | désérialisation typée |
| hive_flutter / hive | 1.1.0 / 2.2.3 | persistance locale des statuts |

## Installation

Prérequis : Flutter, Dart, Android SDK et un appareil ou émulateur Android. macOS avec Xcode est nécessaire pour compiler la cible iOS.

```bash
git clone https://github.com/DorianArg/AgriVistaEXAM.git
cd AgriVistaEXAM
flutter pub get
```

Les fichiers générés sont déjà versionnés. Après modification des DTO, les régénérer avec :

```bash
dart run build_runner build
```

## Lancement et validation

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

Construire l’APK Android debug :

```bash
flutter build apk --debug
```

Le projet a été testé sur un appareil Android réel Samsung SM S926U sous Android 16.

## Source des données

`https://utrera.ludovic.aflokkat-projet.fr/getInterventions.json`

- requête HTTP GET ;
- source distante en lecture seule et jamais modifiée ;
- aucun backend à installer ;
- aucune configuration Firebase ou Supabase ;
- connexion réseau nécessaire pour charger les interventions ;
- changements de statut enregistrés uniquement en local.

## Persistance locale

Hive conserve uniquement les changements de statut dans la box `intervention_statuses` :

```text
JSON distant + statuts locaux Hive → données affichées
```

Le JSON reste la référence initiale et Hive surcharge seulement le statut. Il n’existe aucun cache complet du JSON et l’historique distant n’est pas modifié.

## État du projet

- périmètre fonctionnel obligatoire terminé ;
- Android testé sur appareil réel ;
- 86 tests automatisés réussis ;
- `flutter analyze` sans anomalie ;
- APK debug construit ;
- persistance après fermeture complète et relance vérifiée manuellement par le développeur ;
- projet iOS généré.

Le projet iOS est généré et conservé dans le repository. Sa compilation n'a pas été exécutée dans l'environnement Windows utilisé pour le développement et nécessite macOS avec Xcode.

## Tests

La suite compte **86 tests automatisés réussis**. Elle couvre : Domain, transitions de statut, parsing, mapping, JSON invalide, erreurs réseau, Hive, fusion distant/local, Riverpod, retry, recherche, filtres, détail, profil et navigation.

Aucun pourcentage de couverture n’est annoncé.

### Validation manuelle Android

La recette Android a été réalisée manuellement sur appareil réel par le développeur. Elle couvre l’affichage de la liste, la recherche, les filtres, le détail, le changement de statut, le retour liste, le profil, la persistance après fermeture complète et relance, ainsi que l’absence d’overflow visible.

Aucune validation manuelle iOS n’est déclarée.

## Limites

- premier chargement dépendant du réseau ;
- pas de cache complet offline-first ;
- aucune synchronisation serveur ou résolution de conflit ;
- historique non enrichi localement ;
- compilation iOS non exécutée sous Windows ;
- fonctionnalités bonus non développées.

Les documents complets sont accessibles dans la section Livrables : [dossier de conception](docs/Dossier_conception_AgriVista_Field_Dorian_ARGAILLOT.pdf) et [dossier technique](docs/Dossier_technique_AgriVista_Field_Dorian_ARGAILLOT.pdf).
