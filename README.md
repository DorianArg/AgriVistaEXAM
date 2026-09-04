# AgriVista Field

## Présentation

AgriVista Field est une application mobile interne destinée aux techniciens de terrain d’AgriVista, une entreprise corse qui installe et entretient des stations de capteurs pour des exploitations agricoles et viticoles.

L’application remplace la consultation papier des interventions de maintenance. Elle charge le planning depuis le JSON fourni par l’équipe pédagogique, permet de rechercher et filtrer les interventions, d’en consulter le détail puis de faire progresser leur statut. Les changements sont conservés localement sur l’appareil.

## Fonctionnalités

- chargement en lecture seule d’un JSON distant avec Dio ;
- désérialisation en objets typés et validation des données ;
- liste des interventions avec station, domaine, priorité, statut et date prévue ;
- recherche par station, domaine ou description ;
- filtres par statut et priorité ;
- détail complet avec localisation, description et historique ;
- transitions `planifiee → en_cours → terminee` ;
- persistance locale des statuts avec Hive ;
- profil dynamique alimenté par le technicien du JSON ;
- états loading, data, empty et error distincts ;
- retry manuel avec le bouton « Réessayer ».

L’application n’intègre pas de backend, de synchronisation distante ni de cache complet du JSON.

## Stack technique

Les versions ci-dessous proviennent de l’environnement de développement et de `pubspec.lock`.

| Technologie | Version | Rôle |
|---|---:|---|
| Flutter | 3.44.8 | Framework mobile et widgets Material 3 |
| Dart | 3.12.2 | Langage de l’application et du Domain |
| flutter_riverpod | 3.4.2 | Injection des dépendances et gestion d’état |
| dio | 5.11.0 | Lecture HTTP du JSON distant |
| freezed / freezed_annotation | 3.2.5 / 3.1.0 | Définition et génération des DTO immuables |
| json_serializable / json_annotation | 6.14.1 / 4.12.0 | Génération de la désérialisation JSON |
| hive_flutter / hive | 1.1.0 / 2.2.3 | Stockage local clé-valeur des statuts |
| build_runner | 2.15.1 | Exécution des générateurs de code |
| flutter_lints | 6.0.0 | Règles d’analyse statique |

Ces bibliothèques open source sont distribuées via [pub.dev](https://pub.dev/). Leurs licences respectives sont consultables depuis les pages de chaque package.

## Prérequis

- Flutter 3.44.8 ou une version compatible ;
- Dart 3.12.2, fourni avec le SDK Flutter utilisé ;
- Android SDK et un appareil ou émulateur Android ;
- accès réseau lors du premier chargement des interventions ;
- macOS et Xcode pour construire et tester la cible iOS.

La compilation iOS n'a pas pu être exécutée dans l'environnement Windows utilisé pour le développement.

## Installation

Le dépôt configuré pour ce projet est `https://github.com/DorianArg/AgriVistaEXAM`.

```bash
git clone https://github.com/DorianArg/AgriVistaEXAM.git
cd AgriVistaEXAM
flutter pub get
```

Les fichiers Freezed/json_serializable sont déjà présents dans le dépôt. Pour les régénérer après une modification des DTO :

```bash
dart run build_runner build --delete-conflicting-outputs
```

Lancer ensuite l’application sur un appareil disponible :

```bash
flutter devices
flutter run
```

## Source JSON

Les données proviennent de :

`https://utrera.ludovic.aflokkat-projet.fr/getInterventions.json`

Cette ressource est utilisée uniquement en lecture. L’application ne modifie jamais le JSON et aucun backend n’a été développé. Comme seul le statut modifié est stocké dans Hive, un premier chargement nécessite l’accès au JSON distant.

## Architecture

Le projet applique une Clean Architecture organisée selon la relation suivante :

```text
Presentation → Domain ← Data
```

- **Domain** : entités, contrat abstrait du repository, use cases et transitions métier. Cette couche reste en Dart pur et ne dépend ni de Flutter, ni de Riverpod, Dio ou Hive.
- **Data** : source Dio, DTO Freezed/json_serializable, mappers, stockage Hive et implémentation du repository.
- **Presentation** : pages, widgets Material 3, providers Riverpod, filtres et représentation des états asynchrones.
- **App** : composition root, injection des implémentations, navigation et constantes globales.
- **Core** : erreurs typées, client réseau, thème, formateur de date et vues d’état communes.

Le flux d’exécution principal est :

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

## Arborescence simplifiée

```text
lib/
├── app/
│   ├── app.dart
│   ├── app_constants.dart
│   ├── app_shell.dart
│   └── bootstrap.dart
├── core/
│   ├── errors/
│   ├── network/
│   ├── theme/
│   ├── utils/
│   └── widgets/
├── features/
│   ├── interventions/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── mappers/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── pages/
│   │       ├── providers/
│   │       └── widgets/
│   └── profile/
│       └── presentation/
│           ├── pages/
│           └── widgets/
└── main.dart
```

## Gestion d’état avec Riverpod

- des `Provider` exposent le repository et les use cases ;
- `interventionsProvider`, basé sur `AsyncNotifier`, porte l’unique état métier partagé de la liste et du profil ;
- `AsyncValue` représente explicitement loading, data et error ;
- un `Notifier` séparé conserve les critères de recherche et de filtres ;
- `ref.watch` reconstruit l’interface lorsque l’état change ;
- `ref.read` déclenche le retry ou la progression du statut.

Le retry automatique Riverpod est désactivé : seul le bouton « Réessayer » relance le chargement.

## Chargement et validation du JSON

```text
Dio
 ↓
RemoteDataSource
 ↓
DTO Freezed/json_serializable
 ↓
Mapper
 ↓
Entités Domain
```

Le mapper convertit notamment `en_cours` en `StatutIntervention.enCours` et les dates ISO en `DateTime`. Les champs obligatoires, valeurs d’énumération, dates et coordonnées sont validés. Une réponse incohérente produit une `DataParsingFailure` ; aucune liste partiellement corrompue n’est affichée.

## Persistance locale

Hive utilise la box `intervention_statuses` avec la structure suivante :

```text
interventionId → statut
```

Au chargement, le repository fusionne les interventions du JSON avec les éventuelles surcharges Hive. Le JSON reste la référence de la liste : une clé Hive devenue inconnue ne crée aucune intervention fictive.

Seul le statut est persisté. Le contenu JSON complet et l’historique distant ne sont ni copiés ni enrichis localement.

## Modification du statut

La règle métier se trouve dans le Domain :

```text
planifiee → en_cours → terminee
```

L’ordre d’une mise à jour est le suivant :

1. validation de la transition par le use case ;
2. écriture du nouveau statut dans Hive ;
3. attente de la réussite de l’écriture ;
4. mise à jour de l’état Riverpod ;
5. reconstruction automatique de la liste et du détail.

Si Hive échoue, l’ancien statut est conservé et l’utilisateur reçoit un message d’erreur. L’interface n’affiche pas de réussite anticipée.

## Gestion des erreurs

Les erreurs techniques sont converties en Failure typées :

- `NetworkFailure` ;
- `RequestTimeoutFailure` ;
- `HttpFailure` ;
- `DataParsingFailure` ;
- `LocalStorageFailure` ;
- `InvalidStatusTransitionFailure` ;
- `UnknownFailure`.

La Presentation transforme ces types en messages compréhensibles. Les exceptions Dio ou Hive ne sont jamais affichées directement.

## Tests et qualité

Exécuter les contrôles avec :

```bash
dart format .
flutter analyze
flutter test
flutter build apk --debug
```

La validation finale compte **86 tests réussis**. Ils couvrent le parsing, le mapping, les règles Domain, les transitions, Dio, les erreurs réseau, Hive, la fusion distant/local, Riverpod, le retry manuel, les filtres, le détail, le profil et la navigation. Aucun pourcentage de couverture n’est annoncé.

### Tests automatisés

Les tests utilisent des fakes, un adaptateur Dio contrôlé et des répertoires Hive temporaires. Ils ne dépendent ni du serveur réel, ni du stockage de l’utilisateur, ni de leur ordre d’exécution.

### Validation manuelle

Le parcours de recette à consigner par le développeur comprend :

- lancement Android et affichage de la liste réelle ;
- recherche et filtres de statut/priorité ;
- ouverture du détail et retour liste ;
- progression du statut ;
- accès au profil ;
- fermeture puis relance pour vérifier la persistance ;
- contrôle visuel de l’absence d’overflow.

Le lancement technique a été confirmé sur un Samsung SM S926U sous Android 16. Les interactions tactiles et la validation visuelle restent sous la responsabilité du développeur et ne sont pas attribuées à Codex.

## Limites

- aucun cache complet du JSON ;
- premier chargement dépendant du réseau ;
- aucune synchronisation avec un serveur ;
- historique distant non enrichi localement ;
- compilation iOS non exécutée sous Windows ;
- aucune fonctionnalité optionnelle du sujet ajoutée.

## Améliorations futures

- cache local complet et mode hors ligne ;
- synchronisation serveur et résolution de conflits ;
- photos et notes d’intervention ;
- cartographie des stations ;
- tableau de bord ;
- authentification ;
- mise en page tablette spécialisée ;
- thème sombre.

Ces éléments sont uniquement des pistes d’évolution et ne font pas partie de la version livrée.

## Documentation

- le sujet officiel et le dossier de conception sont conservés dans `docs/` ;
- la source Markdown du dossier technique se trouve dans [`docs/dossier_technique.md`](docs/dossier_technique.md).
