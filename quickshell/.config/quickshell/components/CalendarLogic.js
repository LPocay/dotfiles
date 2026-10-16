function daysInMonth(year, month) {
  return new Date(year, month + 1, 0).getDate();
}

// Grilla fija de 6 semanas (42 celdas), semana iniciando en domingo.
// Date normaliza días fuera de rango, cubriendo mes anterior y siguiente.
function dateForCell(year, month, index) {
  const firstWeekday = new Date(year, month, 1).getDay();
  return new Date(year, month, 1 - firstWeekday + index);
}

function sameDay(a, b) {
  return !!a && !!b
    && a.getFullYear() === b.getFullYear()
    && a.getMonth() === b.getMonth()
    && a.getDate() === b.getDate();
}
