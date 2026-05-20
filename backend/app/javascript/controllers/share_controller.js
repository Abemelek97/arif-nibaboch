import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["label"];
  static values = {
    url: String,
    title: String,
  };

  async share() {
    const shareData = {
      title: this.titleValue,
      url: this.urlValue,
    };

    try {
      if (navigator.share) {
        await navigator.share(shareData);
        this.notify("Shared");
        return;
      }

      await navigator.clipboard.writeText(this.urlValue);
      this.notify("Link copied");
    } catch (error) {
      if (error?.name === "AbortError") return;
      this.notify("Copy failed", "error");
    }
  }

  notify(text, type = "success") {
    if (window.toast) {
      window.toast(text, { type });
      return;
    }

    if (!this.hasLabelTarget) return;

    const original = this.labelTarget.textContent;
    this.labelTarget.textContent = text;
    clearTimeout(this.flashTimeout);
    this.flashTimeout = setTimeout(() => {
      this.labelTarget.textContent = original;
    }, 2000);
  }
}
