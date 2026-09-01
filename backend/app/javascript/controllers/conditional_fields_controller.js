import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["toggle", "field"];

  connect() {
    this.update();
  }

  toggle() {
    this.update();
  }

  update() {
    const enabled = this.toggleTargets.some((toggle) => toggle.checked);
    this.fieldTargets.forEach((field) => {
      field.classList.toggle("hidden", !enabled);
      field.querySelectorAll("input, select, textarea").forEach((control) => {
        control.disabled = !enabled;
      });
    });
  }
}
