function daysInMonth(year, month) {
  return new Date(year, month + 1, 0).getDate();
}

function dateForCell(year, month, index) {
  // 1. Averiguar qué día de la semana cae el día 1.
  // 2. Calcular el día relativo usando el índice.
  // 3. Construir y devolver una fecha real.
}
