/**
 * ACME Corp – Custom Login Theme JavaScript
 *
 * Demonstrates that you can use any JavaScript in Keycloak custom themes.
 * This file is referenced directly in login.ftl via:
 *   <script src="${url.resourcesPath}/js/custom-login.js"></script>
 *
 * Features demonstrated here:
 *   - Canvas-based particle / network animation
 *   - Typewriter animation
 *   - Password visibility toggle
 *   - Form submit loading state
 *   - Input focus micro-interactions
 *
 * You could also load external frameworks (Alpine.js, React, Vue, etc.)
 * from a CDN or bundle them into the theme's resources directory.
 */

'use strict';

/* ── 1. Particle / Network Background ─────────────────────────────────── */
(function initParticles() {
    const canvas = document.getElementById('particle-canvas');
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    let particles = [];
    let rafId;

    /* Resize canvas to fill the viewport */
    function resize() {
        canvas.width  = window.innerWidth;
        canvas.height = window.innerHeight;
    }
    window.addEventListener('resize', resize, { passive: true });
    resize();

    /* Each particle drifts slowly and connects to nearby neighbours */
    class Particle {
        constructor() { this.reset(true); }

        reset(randomY) {
            this.x       = Math.random() * canvas.width;
            this.y       = randomY ? Math.random() * canvas.height : canvas.height + 10;
            this.size    = Math.random() * 1.8 + 0.4;
            this.speedX  = (Math.random() - 0.5) * 0.45;
            this.speedY  = -(Math.random() * 0.4 + 0.15);
            this.opacity = Math.random() * 0.55 + 0.15;
            this.color   = Math.random() > 0.5 ? '#6C63FF' : '#00D4FF';
        }

        update() {
            this.x += this.speedX;
            this.y += this.speedY;
            if (this.y < -10 || this.x < -10 || this.x > canvas.width + 10) {
                this.reset(false);
            }
        }

        draw() {
            ctx.save();
            ctx.globalAlpha = this.opacity;
            ctx.fillStyle   = this.color;
            ctx.beginPath();
            ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
            ctx.fill();
            ctx.restore();
        }
    }

    /* Populate with 90 particles */
    for (let i = 0; i < 90; i++) {
        particles.push(new Particle());
    }

    /* Draw thin lines between particles that are close enough */
    function drawConnections() {
        const maxDist = 110;
        for (let i = 0; i < particles.length; i++) {
            for (let j = i + 1; j < particles.length; j++) {
                const dx   = particles[i].x - particles[j].x;
                const dy   = particles[i].y - particles[j].y;
                const dist = Math.sqrt(dx * dx + dy * dy);
                if (dist < maxDist) {
                    ctx.save();
                    ctx.globalAlpha = (1 - dist / maxDist) * 0.14;
                    ctx.strokeStyle = '#6C63FF';
                    ctx.lineWidth   = 0.6;
                    ctx.beginPath();
                    ctx.moveTo(particles[i].x, particles[i].y);
                    ctx.lineTo(particles[j].x, particles[j].y);
                    ctx.stroke();
                    ctx.restore();
                }
            }
        }
    }

    function animate() {
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        particles.forEach(p => { p.update(); p.draw(); });
        drawConnections();
        rafId = requestAnimationFrame(animate);
    }

    animate();

    /* Pause when tab is hidden to save CPU */
    document.addEventListener('visibilitychange', () => {
        if (document.hidden) {
            cancelAnimationFrame(rafId);
        } else {
            animate();
        }
    });
})();


/* ── 2. Typewriter Animation ──────────────────────────────────────────── */
(function initTypewriter() {
    const el = document.getElementById('tagline');
    if (!el) return;

    const fullText = el.textContent.trim();
    el.textContent = '';

    /* Blinking cursor element */
    const cursor = document.createElement('span');
    cursor.textContent = '|';
    cursor.style.cssText =
        'opacity:0.7; animation: tw-blink 1s step-end infinite;';

    /* Inject @keyframes for blinking */
    const style = document.createElement('style');
    style.textContent = '@keyframes tw-blink { 50% { opacity: 0; } }';
    document.head.appendChild(style);

    let index = 0;

    function type() {
        if (index < fullText.length) {
            el.textContent = fullText.slice(0, ++index);
            el.appendChild(cursor);
            setTimeout(type, 55 + Math.random() * 45);
        } else {
            /* Remove cursor after a short pause */
            setTimeout(() => cursor.remove(), 2200);
        }
    }

    /* Start after card entrance animation (~650ms) */
    setTimeout(type, 900);
})();


/* ── 3. Password Visibility Toggle ───────────────────────────────────── */
function togglePassword() {
    const input     = document.getElementById('password');
    const eyeOpen   = document.getElementById('eye-open');
    const eyeClosed = document.getElementById('eye-closed');

    if (!input) return;

    const isHidden  = input.type === 'password';
    input.type      = isHidden ? 'text' : 'password';
    eyeOpen.style.display   = isHidden ? 'none'  : 'block';
    eyeClosed.style.display = isHidden ? 'block' : 'none';
}


/* ── 4. Form Submit – Loading State ──────────────────────────────────── */
(function initSubmitState() {
    const form   = document.getElementById('kc-form-login');
    const btn    = document.getElementById('kc-login');
    const arrow  = btn && btn.querySelector('.btn-arrow');
    const label  = btn && btn.querySelector('.btn-text');

    if (!form || !btn) return;

    form.addEventListener('submit', () => {
        btn.classList.add('loading');
        if (label) label.textContent = 'Signing in';
        if (arrow) arrow.style.display = 'none';
    });
})();


/* ── 5. Input Icon Micro-Interaction ─────────────────────────────────── */
(function initIconColor() {
    document.querySelectorAll('.input-wrapper input').forEach(input => {
        const wrapper = input.closest('.input-wrapper');
        if (!wrapper) return;
        const icon = wrapper.querySelector('.input-icon');
        if (!icon) return;

        input.addEventListener('focus', () => {
            icon.style.color = '#6C63FF';
        });
        input.addEventListener('blur', () => {
            if (!input.value) icon.style.color = '';
        });
    });
})();


/* ── 6. Developer Easter Egg in Console ──────────────────────────────── */
console.log('%c  ACME CORP  ', [
    'color: #0D0E1A',
    'background: linear-gradient(135deg, #6C63FF, #00D4FF)',
    'font-size: 14px',
    'font-weight: bold',
    'padding: 6px 14px',
    'border-radius: 4px',
].join(';'));

console.log('%cCustom Keycloak login theme – built from scratch\n%cparticles · animations · floating labels · full JS control',
    'color: #6C63FF; font-weight: 600;',
    'color: #00D4FF;'
);
