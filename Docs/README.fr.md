<h1 align="center">
  <a href="https://keyty.app/fr">
    <img src="../Assets/Application/AppIcon/AppIcon.png" alt="Logo de l'application Keyty" width="128">
    <br />
    <strong>Keyty</strong>
  </a>
  <br>
</h1>

<div align="center">
   <img src="https://img.shields.io/github/v/release/keytyapp/Keyty?style=flat-square" alt="Versions">
   <img src="https://img.shields.io/github/downloads/keytyapp/Keyty/total?style=flat-square" alt="Téléchargements">
   <img src="https://img.shields.io/github/stars/keytyapp/Keyty?style=flat-square" alt="Étoiles">
   <img src="https://img.shields.io/github/license/keytyapp/Keyty?style=flat-square" alt="Licence">
   <img src="https://img.shields.io/badge/platform-macOS-lightgrey?style=flat-square" alt="Compatibilité de la plateforme">
</div>

Keyty est une application gratuite et open source qui visualise vos actions au clavier et à la souris en temps réel,
  afin de rendre les démonstrations, présentations, tutoriels et diffusions en direct plus faciles à suivre.
  Elle offre à votre audience une vue claire de chaque raccourci, clic et saisie pour vous aider à mieux
  communiquer à l'écran.

## Fonctionnalités

### Clavier

![Démo du clavier](Resources/demo.gif)

- Affichage en temps réel des raccourcis clavier, des touches spéciales et du texte saisi
- Styles de superposition personnalisables, thèmes, taille, disposition et durée de fondu
- Filtres pour les frappes modifiées, les touches spéciales, les touches multimédias et les événements de souris

### Souris

<p>
  <img src="Resources/ring_demo.gif" alt="Démo de l'anneau du pointeur" width="49%">
  <img src="Resources/pointer_icon_demo.gif" alt="Démo de l'icône du pointeur" width="49%">
</p>

- Visualisez les clics et actions de défilement de la souris en plus des entrées clavier
- Anneau de mise en évidence du pointeur avec forme, couleur, taille et épaisseur configurables
- Superposition de l'icône du pointeur avec position, taille, arrière-plan et teinte ajustables

## Personnalisation

Keyty peut être ajustée depuis Réglages afin de correspondre à votre flux de travail et à votre style de présentation :

- **Apparence :** Choisissez les styles de superposition du clavier, les thèmes, les couleurs et la taille.
- **Historique :** Conservez une trace visuelle de vos entrées récentes.
- **Filtres :** Contrôlez l'affichage des frappes modifiées, des touches spéciales, des touches multimédias et des événements de souris.
- **Souris :** Configurez les anneaux et les icônes du pointeur, y compris la visibilité, la forme, la couleur, la taille, le décalage, l'arrière-plan et la teinte.
- **Positionnement :** Choisissez l'écran, l'ancrage, la marge et le sens d'empilement.

## Installation

### GitHub

Téléchargez la dernière version depuis [GitHub](https://github.com/keytyapp/Keyty/releases)

### Homebrew

```bash
brew install --cask keytyapp/tap/keyty
```

### Compiler à partir du code source

Pour compiler Keyty localement à partir du code source, consultez [BUILD.md](BUILD.md).

## Autorisations

Keyty a besoin de votre autorisation pour recevoir les événements de macOS afin d'afficher vos frappes clavier et les clics de la souris. Consultez [PERMISSIONS.md](PERMISSIONS.md) pour la configuration et le dépannage.

## Confidentialité

Les événements d'entrée sont traités localement sur votre Mac. Keyty n'enregistre, ne stocke et ne téléverse ni vos frappes clavier, ni le texte saisi, ni les clics de la souris, ni l'activité du pointeur. Consultez [PRIVACY.md](PRIVACY.md) pour plus de détails, y compris les vérifications de mise à jour Sparkle.

## Support

Si Keyty vous est utile, pensez à lui donner une ⭐ sur GitHub. Cela aide davantage de personnes à découvrir le projet et c'est le moyen le plus simple de soutenir son développement.
