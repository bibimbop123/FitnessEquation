// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import { Turbo } from "@hotwired/turbo-rails"
import "controllers"

Turbo.session.drive = false

import jquery from "jquery";
window.jQuery = jquery;
window.$ = jquery;
import Rails from "@rails/ujs"
Rails.start();

document.addEventListener("DOMContentLoaded", function() {
  const checkboxes = document.querySelectorAll(".exercise-checkbox");

  // Load checkbox state from local storage
  checkboxes.forEach(checkbox => {
    const routineId = checkbox.getAttribute("data-routine-id");
    const isChecked = localStorage.getItem(`routine-${routineId}`) === "true";
    checkbox.checked = isChecked;
    if (isChecked) {
      checkbox.closest("tr").classList.add("completed");
    }
  });

  // Add event listener to checkboxes
  checkboxes.forEach(checkbox => {
    checkbox.addEventListener("change", function() {
      const routineId = checkbox.getAttribute("data-routine-id");
      const isChecked = checkbox.checked;
      localStorage.setItem(`routine-${routineId}`, isChecked);
      if (isChecked) {
        checkbox.closest("tr").classList.add("completed");
      } else {
        checkbox.closest("tr").classList.remove("completed");
      }
    });
  });
});

import "chartkick"
import "Chart.bundle"
