import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["option", "submit"]

  connect() {
    this.updateSubmitState()
  }

  toggle() {
    this.updateSubmitState()
  }

  reset() {
    this.optionTargets.forEach((option) => {
      option.checked = false
    })
    this.updateSubmitState()
  }

  updateSubmitState() {
    const hasSelection = this.optionTargets.some((option) => option.checked)
    this.submitTarget.disabled = !hasSelection
  }
}
