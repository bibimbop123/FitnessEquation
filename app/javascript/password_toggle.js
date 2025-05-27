// app/javascript/password_toggle.js

function togglePasswordVisibility(fieldId) {
  const field = document.getElementById(fieldId);
  if (field) {
    field.type = field.type === "password" ? "text" : "password";
  }
}

// Make it globally available
window.togglePasswordVisibility = togglePasswordVisibility;
