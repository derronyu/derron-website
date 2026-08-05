document.addEventListener("DOMContentLoaded", function () {
  const toggle = document.querySelector(".menu-toggle");
  const close = document.querySelector(".menu-close");
  const navigation = document.querySelector(".site-navigation");
  const mobileViewport = window.matchMedia("(max-width: 980px)");
  const backgroundElements = [
    document.querySelector("main"),
    document.querySelector(".site-footer"),
    document.querySelector(".site-brand"),
    document.querySelector(".header-actions")
  ].filter(Boolean);
  let returnFocus = null;
  if (!toggle || !close || !navigation) return;

  function setBackgroundInert(inert) {
    backgroundElements.forEach(function (element) {
      if (inert) element.setAttribute("inert", "");
      else element.removeAttribute("inert");
    });
  }

  function setOpen(open, restoreFocus) {
    const shouldRestoreFocus = restoreFocus !== false;

    navigation.classList.toggle("is-open", open);
    toggle.setAttribute("aria-expanded", String(open));
    toggle.setAttribute("aria-label", open ? "Close menu" : "Open menu");
    document.body.style.overflow = open ? "hidden" : "";
    setBackgroundInert(open);

    if (open) {
      returnFocus = document.activeElement;
      toggle.setAttribute("tabindex", "-1");
      close.focus();
    } else {
      toggle.removeAttribute("tabindex");
      if (shouldRestoreFocus && returnFocus instanceof HTMLElement) returnFocus.focus();
      returnFocus = null;
    }
  }

  function trapFocus(event) {
    if (event.key !== "Tab") return;

    const focusable = Array.from(navigation.querySelectorAll(
      'a[href], button:not([disabled]), [tabindex]:not([tabindex="-1"])'
    ));
    if (focusable.length === 0) return;

    const first = focusable[0];
    const last = focusable[focusable.length - 1];

    if (event.shiftKey && document.activeElement === first) {
      event.preventDefault();
      last.focus();
    } else if (!event.shiftKey && document.activeElement === last) {
      event.preventDefault();
      first.focus();
    }
  }

  toggle.addEventListener("click", function () { setOpen(true); });
  close.addEventListener("click", function () { setOpen(false); });
  navigation.addEventListener("click", function (event) {
    if (event.target.closest("a")) setOpen(false, false);
  });
  navigation.addEventListener("keydown", trapFocus);
  document.addEventListener("keydown", function (event) {
    if (event.key === "Escape" && navigation.classList.contains("is-open")) setOpen(false);
  });
  mobileViewport.addEventListener("change", function (event) {
    if (!event.matches && navigation.classList.contains("is-open")) setOpen(false, false);
  });
});
