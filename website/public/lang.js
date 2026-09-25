// Picks the page language (saved choice → browser language → English)
// and wires the EN/PL toggle. Storage access is guarded because it can
// throw in private mode or when site data is blocked.
(function () {
  var KEY = 'friendsheet_lang';
  var root = document.documentElement;

  function saved() {
    try { return localStorage.getItem(KEY); } catch (e) { return null; }
  }

  function save(lang) {
    try { localStorage.setItem(KEY, lang); } catch (e) { /* ignore */ }
  }

  function apply(lang) {
    root.setAttribute('data-lang', lang);
    root.setAttribute('lang', lang);
    var buttons = document.querySelectorAll('[data-set-lang]');
    for (var i = 0; i < buttons.length; i++) {
      var active = buttons[i].getAttribute('data-set-lang') === lang;
      buttons[i].setAttribute('aria-pressed', active ? 'true' : 'false');
    }
  }

  var initial = saved();
  if (initial !== 'en' && initial !== 'pl') {
    initial = (navigator.language || '').toLowerCase().indexOf('pl') === 0 ? 'pl' : 'en';
  }
  apply(initial);

  document.addEventListener('click', function (event) {
    var target = event.target.closest('[data-set-lang]');
    if (!target) return;
    var lang = target.getAttribute('data-set-lang');
    apply(lang);
    save(lang);
  });
})();
