# Análisis de Jugadores de Fútbol

Este proyecto tiene como objetivo analizar una base de datos de jugadores de fútbol para identificar a los mejores jugadores en diferentes roles y grupos de edad. Utiliza SQL para extraer y procesar los datos, y Python para manejar la conexión a la base de datos y ejecutar consultas.

## Instalación

1. Clona este repositorio.
2. Asegúrate de tener Python instalado.
3. Instala las dependencias necesarias:
   ```bash
   pip install sqlite3 pandas
   ```

## Uso

1. Coloca la base de datos SQLite en la carpeta `data/` con el nombre `processed_database.sqlite`. Se puede descrargar desde [aquí](https://www.kaggle.com/datasets/hugomathien/soccer?resource=download).
2. Ejecuta el script principal:
   ```bash
   python main.py
   ```
3. El script obtendra la base de datos y realizara todo el preprocesamiento necesario y genera la nueva base de datos procesada en `data/processed_database.sqlite`.
4. En `main.ipynb` se pueden obtener algunas graficas y analisis adicionales.
5. La consulta SQL para obtener los mejores jugadores por rol y grupo de edad se encuentra en `best_players_query.sql`.

## Diccionario de datos - Atributos de jugadores

Database: `data/processed_database.sqlite`

| Valor               | Descripcion                                                          |
| ------------------- | -------------------------------------------------------------------- |
| attacking_work_rate | Indica qué tan activo es el jugador al atacar (Low, medium, high).   |
| defensive_work_rate | Indica qué tan activo es el jugador al defender (Low, medium, high). |
| crossing            | Precisión en centros al área.                                        |
| finishing           | Capacidad de definición y anotar goles.                              |
| heading_accuracy    | Precisión en remates de cabeza.                                      |
| short_passing       | Habilidad para realizar pases cortos precisos.                       |
| volleys             | Habilidad para rematar de volea.                                     |
| shot_power          | Potencia de los tiros.                                               |
| penalties           | Habilidad para ejecutar penales.                                     |
| dribbling           | Habilidad para regatear y mantener el control del balón.             |
| curve               | Capacidad para aplicar efecto a los tiros y pases.                   |
| free_kick_accuracy  | Precisión en tiros libres.                                           |
| long_passing        | Habilidad para realizar pases largos precisos.                       |
| ball_control        | Habilidad para controlar el balón.                                   |
| vision              | Capacidad para ver y ejecutar jugadas.                               |
| acceleration        | Velocidad de aceleración del jugador.                                |
| sprint_speed        | Velocidad máxima del jugador.                                        |
| agility             | Habilidad para cambiar de dirección rápidamente.                     |
| reactions           | Rapidez de respuesta a situaciones del juego.                        |
| balance             | Capacidad para mantener el equilibrio.                               |
| jumping             | Altura y capacidad de salto.                                         |
| stamina             | Resistencia física durante el partido.                               |
| strength            | Fuerza física del jugador.                                           |
| aggression          | Nivel de agresividad en el juego.                                    |
| interceptions       | Habilidad para interceptar pases del equipo contrario.               |
| marking             | Habilidad para marcar a los jugadores rivales.                       |
| standing_tackle     | Habilidad para realizar entradas de pie.                             |
| sliding_tackle      | Habilidad para realizar entradas deslizantes.                        |
| gk_diving           | Habilidad del portero para lanzarse y atajar balones.                |
| gk_handling         | Habilidad del portero para atrapar y controlar el balón.             |
| gk_kicking          | Habilidad del portero para realizar saques largos y potentes.        |
| gk_positioning      | Habilidad del portero para posicionarse correctamente.               |
| gk_reflexes         | Rapidez de reflejos del portero.                                     |

## Atributos generales

- nivel (liga)
- reactions
- stamina
- strength
- short_passing
- dribbling
- ball_control
- vision
- reactions
- balance
- stamina
- positioning

## Atributos por rol

### Portero

- jumping
- gk_diving
- gk_handling
- gk_kicking
- gk_positioning
- gk_reflexes
- height (De la tabla Player)

### Defensa

- defensive_work_rate
- long_passing
- strength
- aggression
- interceptions
- marking
- standing_tackle
- sliding_tackle

### Volante - Centrocampista

- attacking_work_rate
- finishing
- heading_accuracy
- long_shots
- penalties
- free_kick_accuracy
- acceleration
- sprint_speed
- agility
- interceptions

### Delantero

- attacking_work_rate
- finishing
- heading_accuracy
- volleys
- shot_power
- penalties
- curve
- acceleration
- sprint_speed
- jumping
- strength

### Extremos

- attacking_work_rate
- crossing
- shot_power
- long_shots
- free_kick_accuracy
- long_passing
- acceleration
- sprint_speed
- agility
- strength
- aggression
