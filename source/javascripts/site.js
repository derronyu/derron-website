document.addEventListener("DOMContentLoaded", function () {
  const toggle = document.querySelector(".menu-toggle");
  const close = document.querySelector(".menu-close");
  const navigation = document.querySelector(".site-navigation");
  if (!toggle || !close || !navigation) return;

  function setOpen(open) {
    navigation.classList.toggle("is-open", open);
    toggle.setAttribute("aria-expanded", String(open));
    toggle.setAttribute("aria-label", open ? "Close menu" : "Open menu");
    document.body.style.overflow = open ? "hidden" : "";
  }

  toggle.addEventListener("click", function () { setOpen(true); });
  close.addEventListener("click", function () { setOpen(false); });
  navigation.addEventListener("click", function (event) {
    if (event.target.closest("a")) setOpen(false);
  });
  document.addEventListener("keydown", function (event) {
    if (event.key === "Escape") setOpen(false);
  });
});
