Proyecto Nomad Wallpaper

## Fase 1 - Preparar el proyecto
Primero vamos a organizar la estructura del repositorio.

Paso 1. Crear el directorio del proyecto

Yo no trabajaría directamente desde ~/.local/bin.

Crearía un repositorio independiente.

Por ejemplo:
mkdir -p ~/Projects
cd ~/Projects

mkdir nomad-wallpaper

cd nomad-wallpaper

Paso 2. Crear la estructura

Vamos a dejarla preparada desde el inicio.
nomad-wallpaper/
├── LICENSE
├── README.md
├── CHANGELOG.md
├── .gitignore
├── install.sh
├── uninstall.sh
├── nomad-wallpaper
├── systemd/
│   ├── nomad-wallpaper.service
│   └── nomad-wallpaper.timer
└── docs/

Todavía no vamos a escribir nada.

Solo quiero crear la estructura.

Puedes hacerlo con:

mkdir systemd
mkdir docs

touch README.md
touch CHANGELOG.md
touch LICENSE
touch .gitignore
touch install.sh
touch uninstall.sh

Y copia tu script:

cp ~/.local/bin/nomad-wallpaper .

Y los servicios:

cp ~/.config/systemd/user/nomad-wallpaper.service systemd/

cp ~/.config/systemd/user/nomad-wallpaper.timer systemd/

### Fase 1 - Completado.

## Fase 2

Escribir un README profesional.

No un README enorme.

Uno que cualquiera pueda leer.

Incluirá:

Introducción

Características

Cómo funciona

Instalación

Configuración

Uso

Actualizar wallpapers

Modificar intervalo

Desinstalar

Licencia

## Fase 3

Crear un buen .gitignore.

## Fase 4

Crear un install.sh.

La idea es que un usuario haga:

git clone ...

cd nomad-wallpaper

./install.sh

## Fase 5

Crear un uninstall.sh.

Que elimine absolutamente todo.

## Fase 6

Crear el CHANGELOG.md.

Empezando por:

v1.0.0

Initial release

- Random playlist
- No repeated wallpapers
- Plasma 6 support
- systemd timer

## Fase 7

Elegir la licencia.

Yo usaría MIT.

Es sencilla.

Permite que cualquiera lo use.

## Fase 8

Crear el repositorio Git.

git init

## Fase 9

Primer commit.

## Fase 10

Crear el repositorio en GitHub

## Fase 11

Subirlo.

## Fase 12

Crear el primer Release (v1.0.0).

