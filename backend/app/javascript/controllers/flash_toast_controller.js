import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { message: String, type: String };

  connect() {
    this.retryCount = 0;
    this.maxRetries = 20;

    if (this.messageValue) {
      this.showToast();
    } else {
      this.element.remove();
    }
  }

  showToast() {
    if (typeof window.toast === "function") {
      window.toast(this.messageValue, { type: this.typeValue });
      this.element.remove();
    } else if (this.retryCount >= this.maxRetries) {
      consoole.warn("Toast controller not available after maximum retries");
      this.element.remove();
    } else {
      this.retryCount++;
      // Retry after a short delay if toast controller hasn't connected yet
      setTimeout(() => this.showToast(), 50);
    }
  }
}
