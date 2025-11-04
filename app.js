// Smooth scroll to section
function scrollToSection(sectionId) {
  const element = document.getElementById(sectionId);
  if (element) {
    element.scrollIntoView({
      behavior: 'smooth',
      block: 'start'
    });
  }
}

// Add animation on scroll
function addScrollAnimations() {
  const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
  };

  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.style.opacity = '1';
        entry.target.style.transform = 'translateY(0)';
      }
    });
  }, observerOptions);

  // Observe all phase cards and benefit items
  const animatedElements = document.querySelectorAll(
    '.phase-card, .benefit-item, .pricing-card, .timeline-item, .activity-item'
  );

  animatedElements.forEach(el => {
    el.style.opacity = '0';
    el.style.transform = 'translateY(20px)';
    el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
    observer.observe(el);
  });
}

// Initialize animations when DOM is loaded
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', addScrollAnimations);
} else {
  addScrollAnimations();
}

// Add parallax effect to hero section
window.addEventListener('scroll', () => {
  const hero = document.querySelector('.hero-decoration');
  if (hero) {
    const scrolled = window.pageYOffset;
    hero.style.transform = `translateY(${scrolled * 0.5}px)`;
  }
});