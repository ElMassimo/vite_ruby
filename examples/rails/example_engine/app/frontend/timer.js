export function startTimer (timer, loadedAt = new Date().getTime()) {
  function updateTimer () {
    const millisEllapsed = new Date().getTime() - loadedAt
    timer.innerHTML = Math.floor(millisEllapsed / 1000)
  }

  setInterval(updateTimer, 200)
}
