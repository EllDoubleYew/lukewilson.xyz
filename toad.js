// A little bike ride, entirely local and independent of the page's scroll position.
(() => {
  const toad = document.getElementById("scrolling-toad");
  if (!toad) return;

  const pixelsPerSecond = 65;
  const spriteWidth = toad.width;
  let x = window.innerWidth;
  let previousTime = null;

  function ride(time) {
    if (previousTime !== null) {
      // Avoid jumping across the screen after returning from a background tab.
      const seconds = Math.min((time - previousTime) / 1000, 0.1);
      x -= pixelsPerSecond * seconds;
    }
    previousTime = time;
    if (x <= -spriteWidth) x = window.innerWidth;
    toad.style.transform = `translateX(${x}px)`;
    requestAnimationFrame(ride);
  }

  window.addEventListener("resize", () => {
    x = Math.min(x, window.innerWidth);
  });
  requestAnimationFrame(ride);
})();
