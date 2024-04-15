const hovercardBufferPx = 5;
var observer = new IntersectionObserver(function(entries) {
  entries.forEach(function(entry) {
    if (!entry.target.classList.contains('hover-card')) {
        return;
    }
    const hoverCard = entry.target;
    if (hoverCard.style.display != 'none') {
      window.requestAnimationFrame(function() {
        var hoverCardRect = hoverCard.getBoundingClientRect();
        var fullyInView = hoverCardRect.top >= 0 && hoverCardRect.left >= 0 && hoverCardRect.bottom <= window.innerHeight && hoverCardRect.right <= window.innerWidth;
        if (fullyInView) {
            return;
        }
        const container = hoverCard.closest('.hover-card-container');
        const hoverCardContainerRect = container.getBoundingClientRect();
        var correspondingHoverLink = container.parentElement.querySelector('.hover-link');
        var linkRect = correspondingHoverLink.getBoundingClientRect();
        var linkCenterX = linkRect.left + linkRect.width / 2;
        var linkCenterY = linkRect.top + linkRect.height / 2;
        var viewportCenterX = window.innerWidth / 2;
        var viewportCenterY = window.innerHeight / 2;
        var linkQuadrant = linkCenterX < viewportCenterX
          ? linkCenterY < viewportCenterY ? 'top left' : 'bottom left'
          : linkCenterY < viewportCenterY ? 'top right' : 'bottom right';
        if (linkQuadrant === 'top left') {
          hoverCard.style.top = hovercardBufferPx + 'px';
          hoverCard.style.left = hovercardBufferPx + 'px';
          hoverCard.style.right = 'auto';
        } else if (linkQuadrant === 'bottom left') {
          hoverCard.style.top = 'auto';
          // "container" of hovercard has 0 area and its position does not line up with either the top or bottom of the hover link
          hoverCard.style.bottom = (hoverCardContainerRect.top - linkRect.top) + hovercardBufferPx + 'px';
          hoverCard.style.left = hovercardBufferPx + 'px';
          hoverCard.style.right = 'auto';
        } else if (linkQuadrant === 'bottom right') {
          hoverCard.style.top = 'auto';
          // "container" of hovercard has 0 area and its position does not line up with either the top or bottom of the hover link
          hoverCard.style.bottom = (hoverCardContainerRect.top - linkRect.top) + hovercardBufferPx + 'px';
          hoverCard.style.left = 'auto';
          hoverCard.style.right = linkRect.width + hovercardBufferPx + 'px';
        } else if (linkQuadrant === 'top right') {
          hoverCard.style.top = hovercardBufferPx + 'px';
          hoverCard.style.left = 'auto';
          hoverCard.style.right = linkRect.width + hovercardBufferPx + 'px';
        }
      });
    }
  });
});

document.querySelectorAll('.hover-card').forEach(function(hoverCard) {
  observer.observe(hoverCard);
});