import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"]

  connect() {
    const currentUserId = document.querySelector('meta[name="current-user-id"]')?.content
    if (!currentUserId) return

    let anyVisible = false

    this.itemTargets.forEach(item => {
      const allowedIds = JSON.parse(item.dataset.allowedIds || "[]").map(String)
      
      if (allowedIds.includes(String(currentUserId))) {
        item.classList.remove("hidden")
        anyVisible = true
      } else {
        item.classList.add("hidden")
      }
    })

    if (anyVisible) {
      this.element.classList.remove("hidden")
    }
  }
}
