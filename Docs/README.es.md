<h1 align="center">
  <a href="https://keyty.app">
    <img src="../Assets/Application/AppIcon/AppIcon.png" alt="Logotipo de la app Keyty" width="128">
    <br />
    <strong>Keyty</strong>
  </a>
  <br>
</h1>

<div>
   <img src="https://img.shields.io/github/v/release/keytyapp/Keyty?style=flat-square" alt="Versiones">
   <img src="https://img.shields.io/github/downloads/keytyapp/Keyty/total?style=flat-square" alt="Descargas">
   <img src="https://img.shields.io/github/stars/keytyapp/Keyty?style=flat-square" alt="Estrellas">
   <img src="https://img.shields.io/github/license/keytyapp/Keyty?style=flat-square" alt="Licencia">
   <img src="https://img.shields.io/badge/platform-macOS-lightgrey?style=flat-square" alt="Compatibilidad de plataforma">
</div>

Keyty es una app gratuita y de código abierto que visualiza tus acciones de teclado y ratón en tiempo real,
  haciendo que las demos, presentaciones, tutoriales y transmisiones en directo sean más fáciles de seguir.
  Ofrece a tu audiencia una vista clara de cada atajo, clic y entrada para que puedas comunicarte de forma
  más eficaz en pantalla.

## Características

### Teclado

![Demostración del teclado](Resources/demo.gif)

- Visualización en tiempo real de atajos de teclado, teclas especiales y texto escrito
- Estilos de superposición personalizables, temas, tamaño, disposición y tiempo de desvanecimiento
- Filtros para pulsaciones modificadas, teclas especiales, teclas multimedia y eventos del ratón

### Ratón

<p>
  <img src="Resources/ring_demo.gif" alt="Demostración del anillo del puntero" width="49%">
  <img src="Resources/pointer_icon_demo.gif" alt="Demostración del icono del puntero" width="49%">
</p>

- Visualiza clics y acciones de desplazamiento del ratón junto con la entrada del teclado
- Anillo de resaltado del puntero con forma, color, tamaño y grosor configurables
- Superposición del icono del puntero con posición, tamaño, fondo y tinte ajustables

## Personalización

Keyty puede ajustarse desde Configuración para adaptarse a tu flujo de trabajo y estilo de presentación:

- **Apariencia:** Elige estilos de superposición del teclado, temas, colores y tamaño.
- **Historial:** Mantén un rastro visual de tus entradas recientes.
- **Filtros:** Controla si aparecen pulsaciones modificadas, teclas especiales, teclas multimedia y eventos del ratón.
- **Ratón:** Configura anillos e iconos del puntero, incluida la visibilidad, forma, color, tamaño, desplazamiento, fondo y tinte.
- **Ubicación:** Elige la pantalla, anclaje, margen y dirección de apilado.

## Instalación

### GitHub

Descarga la última versión desde [GitHub](https://github.com/keytyapp/Keyty/releases)

### Homebrew

```bash
brew install --cask keytyapp/tap/keyty
```

### Compilar desde el código fuente

Para compilar Keyty localmente desde el código fuente, consulta [BUILD.md](BUILD.md).

## Permisos

Keyty necesita tu permiso para recibir eventos de macOS y así poder mostrar tus pulsaciones de teclado y clics del ratón. Consulta [PERMISSIONS.md](PERMISSIONS.md) para la configuración y solución de problemas.

## Privacidad

Los eventos de entrada se procesan localmente en tu Mac. Keyty no graba, almacena ni sube tus pulsaciones de teclado, texto escrito, clics del ratón ni actividad del puntero. Consulta [PRIVACY.md](PRIVACY.md) para más detalles, incluidas las comprobaciones de actualización de Sparkle.

## Soporte

Si Keyty te resulta útil, considera darle una ⭐ en GitHub. Ayuda a que más gente descubra el proyecto y es la forma más sencilla de apoyar su desarrollo.
