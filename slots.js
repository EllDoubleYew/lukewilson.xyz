(() => {
  const button = document.querySelector('.slot-stamp');
  if (!button) return;
  const reels = [...button.querySelectorAll('.slot-reels span')];
  const message = button.querySelector('.slot-message');
  const status = document.getElementById('slot-status');
  const symbols = ['7', '★', '♦', '♣', '♥'];
  const pick = () => Math.floor(Math.random() * symbols.length);
  const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)');

  function rainCoins() {
    if (reducedMotion.matches) return;
    const rain = document.createElement('div');
    rain.className = 'slot-coin-rain';
    rain.setAttribute('aria-hidden', 'true');
    for (let i = 0; i < 60; i++) {
      const coin = document.createElement('span');
      coin.className = 'slot-coin';
      coin.textContent = '$';
      coin.style.left = `${Math.random() * 100}%`;
      coin.style.animationDelay = `${Math.random() * 0.8}s`;
      coin.style.setProperty('--drift', `${Math.random() * 100 - 50}px`);
      rain.append(coin);
    }
    document.body.append(rain);
    window.setTimeout(() => rain.remove(), 2000);
  }

  button.addEventListener('click', () => {
    if (button.disabled) return;
    button.disabled = true;
    button.classList.remove('is-winner');
    message.textContent = 'SPINNING...';
    status.textContent = 'Spinning.';

    // Decide the outcome first so accidental matches never increase the win rate.
    const won = Math.random() < 0.25;
    const first = pick();
    const result = won ? [first, first, first] : [first, pick(), pick()];
    if (!won && result.every(value => value === first)) {
      result[2] = (first + 1) % symbols.length;
    }
    const timer = reducedMotion.matches ? null : window.setInterval(() => {
      reels.forEach(reel => { reel.textContent = symbols[pick()]; });
    }, 75);

    window.setTimeout(() => {
      if (timer !== null) window.clearInterval(timer);
      reels.forEach((reel, i) => { reel.textContent = symbols[result[i]]; });
      message.textContent = won ? 'YOU WIN!' : 'TRY AGAIN!';
      status.textContent = won ? 'Three matching symbols! You win!' : 'No match. Try again!';
      button.classList.toggle('is-winner', won);
      button.disabled = false;
      if (won) rainCoins();
    }, 1500);
  });
})();
