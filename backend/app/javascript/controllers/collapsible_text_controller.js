import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["content", "toggle"];
  static values = {
    clampClass: { type: String, default: "line-clamp-4" },
    showMoreText: { type: String, default: "Show more" },
    showLessText: { type: String, default: "Show less" },
  };

  connect() {
    if (this.contentTarget.scrollHeight > this.contentTarget.clientHeight) {
      this.toggleTarget.classList.remove("hidden");
    }
  }

  toggle() {
    if (this.contentTarget.classList.contains(this.clampClassValue)) {
      this.contentTarget.classList.remove(this.clampClassValue);
      this.toggleTarget.textContent = this.showLessTextValue;
    } else {
      this.contentTarget.classList.add(this.clampClassValue);
      this.toggleTarget.textContent = this.showMoreTextValue;
    }
  }
}
