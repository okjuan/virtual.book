var observer = new IntersectionObserver(function(entries) {
  entries.forEach(function(hoverCard) {
    // If the element is visible and a hovercard
    if (hoverCard.isIntersecting && hoverCard.target.classList.contains('hover-card')) {
      window.requestAnimationFrame(function() {
        var rect = hoverCard.target.getBoundingClientRect();
        var fullyInView = rect.top >= 0 && rect.left >= 0 && rect.bottom <= window.innerHeight && rect.right <= window.innerWidth;
        if (fullyInView) {
            return;
        }
        const container = hoverCard.target.closest('.hover-card-container');
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
          // revert to default
          hoverCard.target.style.top = '0px';
          hoverCard.target.style.right = '0px;'
        } else if (linkQuadrant === 'bottom left') {
          hoverCard.target.style.top = '-' + (rect.height + linkRect.height) + 'px';
          hoverCard.target.style.right = '0px;'
        } else if (linkQuadrant === 'bottom right') {
          hoverCard.target.style.top = '-' + (rect.height + linkRect.height) + 'px';
          hoverCard.target.style.right = linkRect.width + 'px';
        } else if (linkQuadrant === 'top right') {
          hoverCard.target.style.top = '0px';
          hoverCard.target.style.right = linkRect.width + 'px';
        }
      });
    }
  });
});

document.querySelectorAll('.hover-card').forEach(function(hoverCard) {
  observer.observe(hoverCard);
});