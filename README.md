# Documentación de SudokuGameModel

## Introducción

`SudokuGameModel` es una implementación funcional para gestionar el estado del juego de Sudoku. Está diseñado siguiendo principios de inmutabilidad y programación funcional para hacer que el código sea más predecible y menos propenso a errores.

## Estructura del modelo

El modelo contiene toda la información necesaria para representar el estado del juego:

```dart
class SudokuGameModel {
  final List<List<int>> board;           // Matriz 9x9 con los números del tablero (0 = vacío)
  final List<List<bool>> isOriginal;     // Matriz 9x9 que indica qué celdas son originales (no modificables)
  final List<List<bool>> isSelected;     // Matriz 9x9 que indica qué celda está seleccionada
  final List<List<bool>> isHighlighted;  // Matriz 9x9 que indica qué celdas están resaltadas
  final List<List<bool>> isErrorCell;    // Matriz 9x9 que indica qué celdas contienen errores
  final int selectedRow;                 // Fila de la celda seleccionada (-1 si ninguna)
  final int selectedCol;                 // Columna de la celda seleccionada (-1 si ninguna)
  final DifficultLevel difficulty;       // Nivel de dificultad del juego
  final String formattedTime;            // Tiempo formateado (MM:SS)
  final int secondsElapsed;              // Segundos transcurridos
  
  // Constructor que exige todos los campos
  const SudokuGameModel({
    required this.board,
    required this.isOriginal,
    // ...
  });
}
```

## Principio de inmutabilidad

El modelo es completamente inmutable:
- Todos los campos son `final`
- No hay métodos que modifiquen el estado interno
- Cada operación devuelve un nuevo modelo con los cambios aplicados

## Métodos principales

### Inicialización

```dart
factory SudokuGameModel.initialize({DifficultLevel difficulty = DifficultLevel.medium}) {
  // Crea un modelo vacío
  // Genera un tablero de juego
  // Devuelve el modelo inicializado
}
```

Este método estático crea un nuevo modelo con un tablero de juego generado según la dificultad especificada.

### Selección de celda

```dart
SudokuGameModel selectCell(int row, int col) {
  // Crea nuevas matrices para isSelected e isHighlighted
  // Marca la celda seleccionada
  // Resalta la fila, columna y subcuadrícula relacionadas
  // Devuelve un nuevo modelo con los cambios
}
```

Cuando el usuario selecciona una celda, este método:
1. Crea una nueva matriz `isSelected` con todas las celdas desmarcadas
2. Marca la celda seleccionada (row, col) como seleccionada
3. Crea una nueva matriz `isHighlighted` para resaltar fila, columna y subcuadrícula
4. Devuelve un nuevo modelo con estas matrices actualizadas

### Ingresar un número

```dart
SudokuGameModel enterNumber(int number) {
  // Verifica si hay una celda seleccionada y no es original
  // Crea una nueva matriz para el tablero
  // Actualiza el número en la celda seleccionada
  // Verifica errores
  // Devuelve un nuevo modelo
}
```

Cuando el usuario ingresa un número:
1. Se verifica que haya una celda seleccionada y que no sea original
2. Se crea una copia del tablero
3. Se actualiza el número en la celda seleccionada
4. Se verifica si hay errores (números duplicados)
5. Se devuelve un nuevo modelo con el tablero actualizado

### Borrar una celda

```dart
SudokuGameModel clearCell() {
  // Verifica si hay una celda seleccionada y no es original
  // Crea una nueva matriz para el tablero
  // Establece la celda seleccionada a 0 (vacía)
  // Verifica errores
  // Devuelve un nuevo modelo
}
```

Similar a `enterNumber`, pero establece la celda a 0 (vacía).

### Verificar errores

```dart
SudokuGameModel checkErrors() {
  // Crea una nueva matriz para isErrorCell
  // Verifica errores en filas
  // Verifica errores en columnas
  // Verifica errores en subcuadrículas
  // Devuelve un nuevo modelo con la matriz isErrorCell actualizada
}
```

Este método marca las celdas que contienen errores (números duplicados en la misma fila, columna o subcuadrícula).

## Flujo de trabajo

1. **Inicialización**: 
   ```dart
   final gameModel = SudokuGameModel.initialize();
   ```

2. **Seleccionar una celda**:
   ```dart
   final updatedModel = gameModel.selectCell(3, 4);
   ```

3. **Ingresar un número**:
   ```dart
   final newerModel = updatedModel.enterNumber(5);
   ```

4. **Borrar una celda**:
   ```dart
   final newestModel = newerModel.clearCell();
   ```

## Cómo extender el modelo

### Agregar un nuevo campo
1. Añade el campo como `final` en la clase
2. Actualiza el constructor principal
3. Actualiza todos los métodos que devuelven un nuevo modelo para incluir el nuevo campo

### Agregar una nueva funcionalidad
1. Crea un nuevo método que retorne un `SudokuGameModel`
2. Implementa la lógica para crear nuevas estructuras de datos según sea necesario
3. Retorna un nuevo modelo con los cambios aplicados

### Ejemplos de extensiones posibles

#### Añadir un sistema de pistas
```dart
SudokuGameModel getHint() {
  // Encuentra una celda vacía
  // Determina el valor correcto
  // Crea una nueva matriz del tablero con la pista añadida
  // Devuelve un nuevo modelo
}
```

#### Añadir sistema de notas
```dart
// Añadir un nuevo campo
final List<List<Set<int>>> notes;

// Nuevo método para gestionar notas
SudokuGameModel toggleNote(int number) {
  // Crea una nueva matriz de notas
  // Añade/elimina el número de las notas de la celda seleccionada
  // Devuelve un nuevo modelo
}
```

## Mejores prácticas
1. **Nunca modifiques directamente** las estructuras de datos del modelo
2. **Siempre crea nuevas copias** de las matrices cuando necesites modificarlas
3. **Mantén los métodos puros** sin efectos secundarios
4. **Actualiza el modelo** a través de los métodos existentes, no crees nuevas instancias manualmente

Siguiendo estos principios, tu juego de Sudoku será más fácil de mantener y extender en el futuro.