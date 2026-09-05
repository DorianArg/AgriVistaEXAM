# Dossier technique — AgriVista Field

## 1. Objet du document

Ce dossier décrit l’état final de l’application Flutter **AgriVista Field** après réalisation du socle obligatoire et des quatre extensions optionnelles. Il présente les choix techniques réellement présents dans le repository, leur validation et leurs limites.

AgriVista Field est destinée aux techniciens chargés de l’installation et de la maintenance de stations de capteurs agricoles et viticoles. L’application consulte les interventions publiées dans un JSON distant, permet de préparer et suivre leur exécution, puis conserve localement les informations terrain non synchronisées.

## 2. Objectifs couverts

Le produit livré couvre les objectifs suivants :

- charger et valider une source JSON distante ;
- afficher la liste et le détail des interventions ;
- rechercher par station, domaine ou description ;
- filtrer par statut et priorité ;
- trier par date prévue, priorité ou statut ;
- faire progresser une intervention de `planifiee` vers `en_cours`, puis `terminee` ;
- conserver localement les statuts modifiés ;
- saisir une note et associer une photo à chaque intervention ;
- présenter un dashboard synthétique ;
- actualiser les données par pull-to-refresh ;
- choisir un thème Système, Clair ou Sombre ;
- adapter la navigation et le détail aux écrans de tablette ;
- représenter explicitement les états de chargement, d’absence de données et d’erreur.

## 3. Fonctionnalités réalisées

### 3.1 Socle obligatoire

- consommation HTTP du JSON officiel avec Dio ;
- parsing typé avec Freezed et `json_serializable` ;
- mapping séparé des DTO vers les entités métier ;
- liste d’interventions ;
- recherche textuelle ;
- filtres couvrant les trois statuts et les trois priorités ;
- détail incluant la date prévue, les coordonnées et l’historique ;
- transition de statut séquentielle et irréversible ;
- surcharge locale du statut distant avec Hive ;
- profil construit depuis le technicien reçu ;
- navigation Material 3 ;
- gestion dédiée des états loading, data, empty et error.

### 3.2 Extensions optionnelles

1. **Dashboard** : total et compteurs par statut et priorité. Un clic sur une métrique ouvre la liste avec le filtre correspondant.
2. **Actualisation et tri** : pull-to-refresh, conservation de la dernière liste valide en cas d’échec, tri par date/priorité/statut et inversion de l’ordre.
3. **Compte rendu terrain** : note locale et photo locale par intervention, modifiables depuis le détail.
4. **Thème et tablette** : thèmes Système/Clair/Sombre persistés, `NavigationRail`, dashboard adapté et master/detail sur les écrans d’au moins 720 px.

## 4. Stack et versions

Les versions ci-dessous correspondent à l’environnement de validation et aux versions résolues dans `pubspec.lock`.

| Élément | Version | Usage |
|---|---:|---|
| Flutter | 3.44.8 | framework multiplateforme, widgets et Material 3 |
| Dart | 3.12.2 | langage et Domain pur |
| flutter_riverpod | 3.4.2 | gestion d’état et injection |
| dio | 5.11.0 | client HTTP du JSON distant |
| freezed | 3.2.5 | génération des DTO immuables |
| freezed_annotation | 3.1.0 | annotations Freezed |
| json_serializable | 6.14.1 | génération de la désérialisation |
| json_annotation | 4.12.0 | annotations JSON |
| hive_flutter | 1.1.0 | initialisation et boxes Hive dans Flutter |
| hive | 2.2.3 | stockage clé/valeur local |
| image_picker | 1.2.3 | sélection d’une image dans la galerie |
| path_provider | 2.1.6 | répertoire permanent de l’application |
| build_runner | 2.15.1 | orchestration de la génération de code |
| flutter_lints | 6.0.0 | règles d’analyse statique |

Aucun package supplémentaire n’est nécessaire pour la navigation ou le responsive.

## 5. Architecture

### 5.1 Principes

L’application suit une Clean Architecture orientée par fonctionnalités :

```text
Presentation → Domain ← Data
```

- **Domain** contient les entités, enums, contrats de repositories et cas d’usage. Il reste en Dart pur et n’importe ni Flutter, ni Riverpod, ni Dio, ni Hive.
- **Data** connaît les détails techniques : HTTP, JSON, Hive, fichiers locaux, DTO et mapping.
- **Presentation** contient les widgets, pages et providers Riverpod.
- **Core** centralise les erreurs, le client réseau, les thèmes, le breakpoint et les widgets d’état génériques.
- **App** contient `MaterialApp`, le shell de navigation et le composition root.

### 5.2 Arborescence réelle

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
│   ├── dashboard/
│   │   └── presentation/
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

Les tests reproduisent cette organisation sous `test/`, avec des tests supplémentaires pour le shell et le responsive dans `test/app`.

### 5.3 Composition root

`bootstrap.dart` exécute les opérations suivantes avant `runApp` :

1. initialise Flutter et Hive ;
2. ouvre les quatre boxes locales ;
3. construit le client Dio et les data sources ;
4. construit les repositories concrets ;
5. injecte repositories, sélecteur de photo et préférence de thème dans `ProviderScope` ;
6. lance `AgriVistaApp`.

Les widgets ne construisent donc pas directement Dio, Hive ou `ImagePicker`.

## 6. Gestion d’état avec Riverpod

| Provider | Responsabilité |
|---|---|
| `interventionsProvider` | chargement global, actualisation et mise à jour optimiste de la liste après changement de statut |
| `interventionFiltersProvider` | recherche, filtres, critère et direction de tri |
| `dashboardSummaryProvider` | projection des interventions en compteurs de synthèse |
| `compteRenduProvider(id)` | lecture et mutation de la note/photo d’une intervention |
| `themeModeProvider` | restauration et modification du `ThemeMode` |
| providers de dépendances | injection des repositories et cas d’usage |

`interventionsProvider` est un `AsyncNotifier`. Lors d’un refresh réussi, il remplace les données. Lors d’un refresh échoué après un premier chargement valide, il conserve la valeur précédente et l’interface affiche un `SnackBar`. Si aucune valeur n’a encore été chargée, l’échec produit un état d’erreur avec l’action « Réessayer ».

Le provider familial du compte rendu isole l’état par identifiant d’intervention. Une écriture locale échouée conserve la dernière valeur valide.

## 7. Source JSON et Dio

### 7.1 Endpoint

```text
GET https://utrera.ludovic.aflokkat-projet.fr/getInterventions.json
```

La source est distante, officielle et en lecture seule. L’application ne la modifie jamais et ne possède pas de backend local.

### 7.2 Configuration réseau

- connexion : 10 secondes ;
- envoi : 10 secondes ;
- réception : 15 secondes ;
- réponse attendue : JSON.

### 7.3 Validation des données

Le `DioInterventionRemoteDataSource` vérifie le code HTTP et la nature objet de la racine JSON. Les DTO Freezed imposent les champs requis. Le mapper contrôle ensuite :

- les chaînes métier non vides ;
- les coordonnées géographiques finies et dans les bornes ;
- les statuts et priorités connus ;
- les dates ISO valides.

Une donnée invalide devient un `DataParsingFailure` et n’entre pas dans le Domain.

### 7.4 Stratégie distant/local

```text
JSON distant + surcharges Hive autorisées → données présentées
```

Le JSON reste la référence pour le technicien, la liste, la description, les coordonnées, les dates et l’historique. Le repository fusionne uniquement les statuts locaux par identifiant. Il n’existe pas de cache complet du JSON : un premier chargement et chaque actualisation nécessitent le réseau.

## 8. Persistance locale

Hive utilise exactement les boxes suivantes :

| Box | Clé | Valeur |
|---|---|---|
| `intervention_statuses` | identifiant d’intervention | `planifiee`, `en_cours` ou `terminee` |
| `intervention_notes` | identifiant d’intervention | texte de la note |
| `intervention_photos` | identifiant d’intervention | chemin du fichier permanent |
| `app_preferences` | `theme_mode` | `system`, `light` ou `dark` |

### 8.1 Statuts

Les statuts distants sont surchargés à la lecture par les valeurs de `intervention_statuses`. La transition métier est validée avant écriture : une intervention terminée ne peut plus progresser.

### 8.2 Notes

Une note est enregistrée indépendamment pour chaque intervention. Elle est relue à chaque ouverture du détail et survit à la fermeture de l’application.

### 8.3 Photos

Les photos **ne sont pas stockées dans Hive**. Le flux est le suivant :

1. `image_picker` sélectionne une image dans la galerie ;
2. `path_provider` fournit le répertoire permanent de l’application ;
3. le fichier est copié dans le sous-répertoire `intervention_photos` avec un nom sûr et unique ;
4. Hive enregistre uniquement le chemin de cette copie ;
5. après remplacement réussi, l’ancienne photo gérée est supprimée ;
6. si l’écriture Hive échoue, la nouvelle copie est nettoyée.

La suppression est volontairement limitée au répertoire géré afin de ne jamais supprimer le fichier source de l’utilisateur.

### 8.4 Préférence de thème

Le choix Système/Clair/Sombre est stocké sous `app_preferences/theme_mode`. La box est ouverte avant l’affichage de l’application et `themeModeProvider` restaure synchroniquement la valeur. `MaterialApp` observe ce provider et applique `theme`, `darkTheme` et `themeMode`.

## 9. Interface et responsive

### 9.1 Thèmes

`AppTheme` produit les deux `ThemeData` Material 3 depuis une couleur graine commune. Les pages utilisent le `ColorScheme` plutôt que des couleurs claires codées localement. Le thème sombre conserve ainsi le contraste et l’identité visuelle sobre de l’application.

### 9.2 Téléphone

Sous 720 px :

- navigation inférieure avec `NavigationBar` ;
- Dashboard, Interventions et Profil comme destinations ;
- ouverture du détail dans une page dédiée ;
- contenus verticaux et défilants.

### 9.3 Tablette

À partir de 720 px :

- `NavigationRail` Material 3 ;
- dashboard centré, contraint et réparti en groupes côte à côte ;
- profil centré avec largeur maximale ;
- master/detail des interventions : liste filtrable à gauche et détail à droite ;
- sélection locale d’une intervention sans navigation pleine page ;
- réutilisation du détail complet, y compris statut, historique, note et photo.

Le breakpoint est centralisé dans `ResponsiveBreakpoints`. Les tests utilisent notamment une surface simulée de 1200 × 900.

## 10. Gestion des erreurs

La hiérarchie `AppFailure` distingue :

- erreur réseau ;
- délai dépassé ;
- erreur HTTP ;
- données invalides ;
- stockage local indisponible ou incohérent ;
- transition de statut invalide ;
- erreur inconnue.

Dio est traduit vers ces erreurs dans la couche Data. Les lectures et écritures Hive vérifient les boxes et convertissent leurs exceptions en `LocalStorageFailure`. L’interface transforme ces types en messages compréhensibles.

Les stratégies de reprise sont adaptées au contexte :

- bouton « Réessayer » après un premier chargement échoué ;
- conservation des données et `SnackBar` après un refresh échoué ;
- conservation de la dernière note/photo valide après une écriture locale échouée ;
- retour au thème précédent si sa persistance échoue.

Une erreur d’initialisation des boxes est remontée explicitement par le bootstrap. Il n’existe pas de mode dégradé sans Hive.

## 11. Tests et validation

### 11.1 Suite automatisée

La suite finale contient **172 tests réussis**. Elle couvre notamment :

- règles Domain et transitions de statut ;
- parsing, validation et mapping JSON ;
- erreurs réseau, HTTP et données invalides ;
- lecture, écriture, fermeture et réouverture de Hive ;
- fusion des statuts distants et locaux ;
- repositories et cas d’usage ;
- providers Riverpod et conservation du dernier état valide ;
- recherche, filtres et tris ;
- dashboard et navigation issue des métriques ;
- pull-to-refresh réussi et échoué ;
- détail, progression du statut et historique ;
- note, sélection simulée, copie et remplacement de photo ;
- préférence et application du thème ;
- navigation téléphone et tablette ;
- master/detail, dashboard et profil à 1200 × 900 ;
- absence d’overflow dans les tailles ciblées.

Aucun accès au stockage photo réel de l’utilisateur n’est effectué par les tests. Les fichiers et boxes nécessaires sont créés dans des répertoires temporaires. Aucun pourcentage de couverture n’est annoncé.

### 11.2 Validation Android

- `flutter build apk --debug` réussi ;
- Samsung SM S926U sous Android 16/API 36 détecté ;
- APK installé et application lancée ;
- démarrage Flutter/Impeller observé sans erreur applicative visible.

Un parcours tactile complet de la photothèque n’est pas revendiqué. La persistance du thème après fermeture et reprise n’est pas revendiquée comme test manuel ; elle est couverte automatiquement au niveau Hive.

### 11.3 Validation tablette

Les comportements tablette sont vérifiés par tests widgets à 1200 × 900. Aucune tablette physique et aucun émulateur tablette n’ont été utilisés.

### 11.4 Validation iOS

La cible iOS est générée et la description d’accès à la photothèque est configurée. Elle n’a pas été compilée dans l’environnement Windows. Une validation iOS nécessite macOS et Xcode.

## 12. Difficultés rencontrées et solutions

| Difficulté | Solution mise en œuvre |
|---|---|
| Conserver le JSON comme référence tout en modifiant un statut | fusion ciblée des statuts Hive par identifiant dans le repository |
| Actualiser sans effacer une liste utilisable en cas d’échec | conservation de l’`AsyncData` précédent et notification par `SnackBar` |
| Garantir un tri déterministe | comparaison métier puis conservation de l’ordre initial en cas d’égalité |
| Pérenniser une photo choisie dans la galerie | copie dans le stockage applicatif avant enregistrement du chemin |
| Éviter les fichiers orphelins lors d’un remplacement | ordre transactionnel simple et nettoyage compensatoire |
| Restaurer le thème avant l’affichage | ouverture de `app_preferences` au bootstrap et lecture synchrone du provider |
| Partager les fonctions mobile et tablette | shell responsive et détail réutilisable en mode page ou panneau intégré |
| Tester les photos sans stockage utilisateur | abstractions injectables et répertoires temporaires |

## 13. Limites connues

- connexion réseau indispensable au premier chargement et aux actualisations ;
- aucun cache complet offline-first du JSON ;
- aucune synchronisation serveur des statuts, notes ou photos ;
- aucune authentification réelle ;
- aucune stratégie de résolution de conflit multi-appareil ;
- historique distant non enrichi par les actions locales ;
- sélection de photo depuis la galerie uniquement ;
- pas de récupération spécifique d’une sélection interrompue par la destruction du processus Android ;
- parcours tactile photo complet non validé dans cette livraison ;
- persistance du thème non vérifiée manuellement après fermeture/reprise ;
- tablette validée par tests widgets uniquement ;
- cible iOS non compilée sous Windows.

## 14. Améliorations futures

- authentification et gestion des habilitations ;
- API d’écriture et synchronisation serveur ;
- cache JSON complet et stratégie offline-first ;
- résolution des conflits et journal de synchronisation ;
- cartographie des stations ;
- internationalisation ;
- ajout local d’événements dans l’historique ;
- compression et téléversement des photos ;
- récupération Android des sélections perdues ;
- animations et transitions avancées ;
- validation sur tablette physique et chaîne CI macOS/iOS.

## 15. Matrice de conformité

### 15.1 Socle obligatoire

| Exigence | État | Preuve technique |
|---|---|---|
| JSON distant officiel | Conforme | Dio et endpoint centralisé |
| DTO et parsing typé | Conforme | Freezed, `json_serializable`, mapper validant |
| Liste des interventions | Conforme | page, cartes et états asynchrones |
| Recherche | Conforme | station, domaine et description |
| Filtre de statut | Conforme | planifiée, en cours, terminée |
| Filtre de priorité | Conforme | haute, moyenne, basse |
| Détail et date prévue | Conforme | page/panneau de détail |
| Historique distant préservé | Conforme | affichage en lecture seule |
| Progression du statut | Conforme | cas d’usage Domain séquentiel |
| Persistance du statut | Conforme | box `intervention_statuses` |
| Erreur Hive explicite | Conforme | `LocalStorageFailure` et vue d’erreur |
| Profil dynamique | Conforme | technicien issu du provider global |
| Navigation commune | Conforme | shell Material 3 |
| Domain en Dart pur | Conforme | aucun import technique dans `domain/` |

### 15.2 Extensions optionnelles

| Extension | État | Preuve technique |
|---|---|---|
| Dashboard | Réalisée | `dashboardSummaryProvider` et cartes filtrantes |
| Pull-to-refresh | Réalisée | `RefreshIndicator` et méthode `recharger` |
| Tri date/priorité/statut | Réalisé | `InterventionSort` et direction réversible |
| Note locale | Réalisée | box `intervention_notes` et formulaire terrain |
| Photo locale | Réalisée | `image_picker`, copie permanente et chemin Hive |
| Thèmes Système/Clair/Sombre | Réalisés | `ThemeMode`, `AppTheme` et `app_preferences` |
| Responsive tablette | Réalisé | breakpoint 720 px et `NavigationRail` |
| Master/detail | Réalisé | liste et détail simultanés sur tablette |

## 16. Commandes de reproduction

```bash
flutter pub get
dart format .
flutter analyze
flutter test
flutter build apk --debug
```

Après modification des DTO générés :

```bash
dart run build_runner build
```

## 17. Conclusion

La livraison finale couvre le socle fonctionnel et les quatre extensions optionnelles. L’architecture sépare les règles métier des détails Flutter, réseau et stockage. Les données distantes demeurent la référence, tandis que Hive et le stockage applicatif prennent en charge les informations locales. Les validations automatisées couvrent les scénarios fonctionnels, les erreurs et les deux familles de layouts, dans les limites de plateformes déclarées ci-dessus.
