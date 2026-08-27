<h1 align="center">
  <a href="https://keyty.app/pt-br">
    <img src="../Assets/Application/AppIcon/AppIcon.png" alt="Logotipo do app Keyty" width="128">
    <br />
    <strong>Keyty</strong>
  </a>
  <br>
</h1>

<div align="center">
   <img src="https://img.shields.io/github/v/release/keytyapp/Keyty?style=flat-square" alt="Versões">
   <img src="https://img.shields.io/github/downloads/keytyapp/Keyty/total?style=flat-square" alt="Downloads">
   <img src="https://img.shields.io/github/stars/keytyapp/Keyty?style=flat-square" alt="Estrelas">
   <img src="https://img.shields.io/github/license/keytyapp/Keyty?style=flat-square" alt="Licença">
   <img src="https://img.shields.io/badge/platform-macOS-lightgrey?style=flat-square" alt="Compatibilidade com a plataforma">
</div>

Keyty é um app gratuito e de código aberto que visualiza suas ações de teclado e mouse em tempo real,
  tornando demos, apresentações, tutoriais e transmissões ao vivo mais fáceis de acompanhar.
  Ele dá ao seu público uma visão clara de cada atalho, clique e entrada para que você possa se
  comunicar com mais eficácia na tela.

## Recursos

### Teclado

![Demonstração do teclado](Resources/demo.gif)

- Exibição em tempo real de atalhos de teclado, teclas especiais e texto digitado
- Estilos de sobreposição personalizáveis, temas, tamanho, layout e tempo de desaparecimento
- Filtros para teclas modificadas, teclas especiais, teclas de mídia e eventos do mouse

### Mouse

<p>
  <img src="Resources/ring_demo.gif" alt="Demonstração do anel do ponteiro" width="49%">
  <img src="Resources/pointer_icon_demo.gif" alt="Demonstração do ícone do ponteiro" width="49%">
</p>

<p align="center">
  <video src="../Assets/Marketing/MouseIcon/mouse-ripples-visualizer-demo1.webm" controls muted playsinline width="720">
    Your browser does not support the video tag.
  </video>
</p>

- Visualize cliques e ações de rolagem do mouse junto com a entrada do teclado
- Anel de destaque do ponteiro com forma, cor, tamanho e espessura configuráveis
- Sobreposição do ícone do ponteiro com posição, tamanho, fundo e tonalidade ajustáveis
- Visualizador de ondas do mouse para destacar cliques durante demonstrações

## Personalização

Keyty pode ser ajustado em Ajustes para combinar com seu fluxo de trabalho e estilo de apresentação:

- **Aparência:** Escolha estilos de sobreposição do teclado, temas, cores e tamanho.
- **Histórico:** Mantenha um rastro visual das suas entradas recentes.
- **Filtros:** Controle se teclas modificadas, teclas especiais, teclas de mídia e eventos do mouse aparecem.
- **Mouse:** Configure anéis, ícones do ponteiro e ondas de clique, incluindo visibilidade, forma, cor, tamanho, deslocamento, fundo e tonalidade.
- **Posicionamento:** Escolha a tela, a âncora, a margem e a direção de empilhamento.

## Instalação

### GitHub

Baixe a versão mais recente no [GitHub](https://github.com/keytyapp/Keyty/releases)

### Homebrew

```bash
brew install --cask keyty
```

### Compilar a partir do código-fonte

Para compilar o Keyty localmente a partir do código-fonte, consulte [BUILD.md](BUILD.md).

## Permissões

O Keyty precisa da sua permissão para receber eventos do macOS e assim mostrar suas teclas pressionadas e cliques do mouse. Consulte [PERMISSIONS.md](PERMISSIONS.md) para configuração e solução de problemas.

## Privacidade

Os eventos de entrada são processados localmente no seu Mac. O Keyty não grava, armazena nem envia suas teclas pressionadas, texto digitado, cliques do mouse ou atividade do ponteiro. Consulte [PRIVACY.md](PRIVACY.md) para mais detalhes, incluindo as verificações de atualização do Sparkle.

## Suporte

Se o Keyty for útil para você, considere dar uma ⭐ no GitHub. Isso ajuda mais pessoas a descobrirem o projeto e é a maneira mais simples de apoiar o desenvolvimento.
