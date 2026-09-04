<h1 align="center">
  <a href="https://keyty.app/it">
    <img src="../Assets/Application/AppIcon/AppIcon.png" alt="Logo dell'app Keyty" width="128">
    <br />
    <strong>Keyty</strong>
  </a>
  <br>
</h1>

<div align="center">
   <img src="https://img.shields.io/github/v/release/keytyapp/Keyty?style=flat-square" alt="Versioni">
   <img src="https://img.shields.io/github/downloads/keytyapp/Keyty/total?style=flat-square" alt="Download">
   <img src="https://img.shields.io/github/stars/keytyapp/Keyty?style=flat-square" alt="Stelle">
   <img src="https://img.shields.io/github/license/keytyapp/Keyty?style=flat-square" alt="Licenza">
   <img src="https://img.shields.io/badge/platform-macOS-lightgrey?style=flat-square" alt="Supporto piattaforma">
</div>

Keyty è un'app gratuita e open source che visualizza in tempo reale le tue azioni su tastiera e mouse,
  rendendo più facili da seguire demo, presentazioni, tutorial e dirette streaming. Offre al tuo pubblico una
  visualizzazione chiara di ogni abbreviazione, clic e input, per comunicare in modo più efficace sullo schermo.

## Funzionalità

### Tastiera

![Demo della tastiera](Resources/demo.gif)

- Visualizzazione in tempo reale di abbreviazioni da tastiera, tasti speciali e testo digitato
- Stili, temi, dimensioni, disposizione e tempi di dissolvenza della sovrapposizione personalizzabili
- Filtri per pressioni di tasti modificati, tasti speciali, tasti multimediali ed eventi del mouse

### Mouse

<p>
  <img src="Resources/ring_demo.gif" alt="Demo dell'anello del puntatore" width="33%">
  <img src="Resources/pointer_icon_demo.gif" alt="Demo dell'icona del puntatore" width="33%">
  <img src="Resources/mouse_ripples_demo.gif" alt="Demo delle increspature del mouse" width="33%">
</p>

- Visualizza clic e azioni di scorrimento del mouse insieme all'input della tastiera
- Anello di evidenziazione del puntatore con forma, colore, dimensione e spessore configurabili
- Sovrapposizione dell'icona del puntatore con posizione, dimensione, sfondo e tinta regolabili
- Visualizzatore di increspature del mouse per evidenziare i clic durante le demo

## Personalizzazione

Keyty può essere configurato dalle Impostazioni per adattarsi al tuo flusso di lavoro e stile di presentazione:

- **Aspetto:** scegli stili, temi, colori e dimensioni della sovrapposizione della tastiera.
- **Cronologia:** mantieni una traccia visiva dei tuoi input recenti.
- **Filtri:** controlla se visualizzare tasti modificati, tasti speciali, tasti multimediali ed eventi del mouse.
- **Mouse:** configura anelli e icone del puntatore, inclusi visibilità, forma, colore, dimensione, scostamento, sfondo e tinta.
- **Posizione:** scegli lo schermo, l'ancoraggio, il margine e la direzione di impilamento.

## Installazione

### GitHub

Scarica la versione più recente da [GitHub](https://github.com/keytyapp/Keyty/releases)

### Homebrew

```bash
brew install --cask keyty
```

### Compilazione dal codice sorgente

Per compilare Keyty localmente dal codice sorgente, consulta [BUILD.md](BUILD.md).

## Permessi

Keyty richiede il tuo permesso per ricevere eventi da macOS e visualizzare le pressioni dei tasti e i clic del mouse. Consulta [PERMISSIONS.md](PERMISSIONS.md) per la configurazione e la risoluzione dei problemi.

## Privacy

Gli eventi di input vengono elaborati localmente sul tuo Mac. Keyty non registra, archivia né carica le pressioni dei tasti, il testo digitato, i clic del mouse o l'attività del puntatore. Consulta [PRIVACY.md](PRIVACY.md) per maggiori dettagli, inclusi i controlli degli aggiornamenti di Sparkle.

## Supporto

Se Keyty ti è utile, considera di assegnare una ⭐ al progetto su GitHub. Aiuta più persone a scoprire il progetto ed è il modo più semplice per sostenerne lo sviluppo.
