import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["checkbox", "submit"];

  connect() {
    this.update();
  }

  toggle() {
    this.update();
  }

  update() {
    this.submitTarget.disabled = !this.checkboxTarget.checked;
  }

  close(event) {
    if (event.detail.success) {
      this.element.closest("dialog")?.close();
    }
  }
}
